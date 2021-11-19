xquery version "3.1";

(:~
 : This is the place to import your own XQuery modules for either:
 :
 : 1. custom API request handling functions
 : 2. custom templating functions to be called from one of the HTML templates
 :)
module namespace api="http://teipublisher.com/api/custom";

declare namespace tei="http://www.tei-c.org/ns/1.0";

(: Add your own module imports here :)
import module namespace rutil="http://exist-db.org/xquery/router/util";
import module namespace templates="http://exist-db.org/xquery/html-templating";
import module namespace app="teipublisher.com/app" at "app.xql";
import module namespace config="http://www.tei-c.org/tei-simple/config" at "config.xqm";
import module namespace vapi="http://teipublisher.com/api/view" at "lib/api/view.xql";
import module namespace errors = "http://exist-db.org/xquery/router/errors";
import module namespace tpu="http://www.tei-c.org/tei-publisher/util" at "lib/util.xql";

declare function api:landing-commentary($request as map(*)) {
    for $entry in collection($config:data-root || "/commentary")//tei:TEI
        let $volume := $entry//tei:teiHeader//tei:ref[@type="volume"]/@target
        group by $volume
        order by $volume
    return 

    <div class="volume">
        <h3>
        {
            let $vol := $entry[1]
            return $vol//tei:teiHeader//tei:sourceDesc//tei:title[not(@type)]/string()
        }
        </h3>

        {for $e in $entry 
        let $p := ($e//tei:text//tei:pb/@n)[1]
        order by number($p)
        return <p><a href="{$e/@xml:id}">{$e//tei:titleStmt/tei:title[not(@type)]/string()}</a></p>}
    </div>
};

declare function api:view-commentary($request as map(*)) {
    let $name := xmldb:decode($request?parameters?name)
    let $entry := collection($config:data-root || "/commentary")/id($name)
    return
        if ($entry) then
            let $template := doc($config:app-root || "/templates/pages/commentary.html")
            let $model := map { 
                "doc": $config:data-root || "/commentary/" || util:document-name($entry),
                "template": "commentary.html"
            }
            return
                templates:apply($template, vapi:lookup#2, $model, tpu:get-template-config($request))
        else
            error($errors:NOT_FOUND, "Document " || $request?parameters?id || " not found")
};

declare function api:view-person($request as map(*)) {
    let $name := xmldb:decode($request?parameters?name)
    let $person := doc($config:data-root || "/people.xml")//tei:listPerson/tei:person[@n = $name]
    return
        if ($person) then
            let $persName := $person/tei:persName
            let $label :=
                if ($persName/tei:surname) then
                    string-join(($persName/tei:forename, $persName/tei:surname), " ")
                else
                    $persName/string()
            let $template := doc($config:app-root || "/templates/pages/person.html")
            let $model := map { 
                "doc": $config:data-root || "/people.xml",
                "xpath": '//tei:listPerson/tei:person[@n = "' || $name || '"]',
                "label": $label,
                "key": $name,
                "template": "person.html"
            }
            return
                templates:apply($template, vapi:lookup#2, $model, tpu:get-template-config($request))
        else
            error($errors:NOT_FOUND, "Document " || $request?parameters?id || " not found")
};

declare function api:view-letter($request as map(*)) {
    let $id := "K_" || xmldb:decode($request?parameters?id)
    let $doc := collection($config:data-root)/id($id)
    let $template := doc($config:app-root || "/templates/pages/escher.html")
    let $model := map {
        "letter-id" : "B" || xmldb:decode($request?parameters?id),
        "data": $doc,
        "doc": "letters/" || util:document-name($doc),
        "template": "escher",
        "title": "Brief " || $doc//tei:titleStmt/tei:title/text()
    }
    return
        templates:apply($template, vapi:lookup#2, $model, tpu:get-template-config($request))
};

declare function api:people($request as map(*)) {
    let $search := $request?parameters?search
    let $view := $request?parameters?view
    let $sortDir := $request?parameters?dir
    let $limit := $request?parameters?limit
    let $start := $request?parameters?start
    let $filter := $request?parameters?filter
    let $people :=
        if ($view = "correspondents") then
            if ($search) then
                doc($config:data-root || "/people.xml")//tei:listPerson/tei:person[ft:query(., 'name:' || $search)][@type="correspondent"]
            else
                doc($config:data-root || "/people.xml")//tei:listPerson/tei:person[@type="correspondent"]
        else
            if ($search) then
                doc($config:data-root || "/people.xml")//tei:listPerson/tei:person[ft:query(., 'name:' || $search)]
            else
                doc($config:data-root || "/people.xml")//tei:listPerson/tei:person
    let $sorted := api:sort($people, $sortDir)
    let $subset := subsequence($sorted, $start, $limit)
    return (
        session:set-attribute($config:session-prefix || ".hits", $people),
        session:set-attribute($config:session-prefix || ".hitCount", count($people)),
        map {
            "count": count($people),
            "results":
                array {
                    for $person in $subset
                    let $name := $person/tei:persName
                    let $label :=
                        if ($name/tei:surname) then
                            string-join(($name/tei:surname, $name/tei:forename), ", ")
                        else
                            $name/string()
                    return
                        map {
                            "id": $person/@xml:id/string(),
                            "name": <a href="{$person/@n}">{$label}</a>,
                            "dates": string-join(($person/tei:birth, $person/tei:death), "–")
                        }
                }
        }
    )  
};

declare function api:sort($people as element()*, $dir as xs:string) {
    let $sorted :=
        sort($people, (), function($person) {
            let $name := $person/tei:persName
            return
                if ($name/tei:surname) then
                    string-join(($name/tei:surname, $name/tei:forename), ", ")
                else
                    $name/text()
        })
    return
        if ($dir = "asc") then
            $sorted
        else
            reverse($sorted)
};

declare function api:person-mentions($node as node(), $model as map(*)) {
    let $mentions := collection($config:data-root || "/letters")//tei:text[ft:query(., 'mentioned:"'||$model?key||'"')]
    where count($mentions) > 0
    return
        <div>
            <h3>Erwähnungen von {$model?label}</h3>
            <h4><a href="../../index.html?facet-mentioned={$model?key}">In Briefen</a>: {count($mentions)}</h4>
        </div>
};

declare function api:person-letters($node as node(), $model as map(*)) {
    let $mentions := collection($config:data-root || "/letters")//tei:text[ft:query(., 'correspondent:"'||$model?key||'"')]
    return
        if (count($mentions) ) then
            <div>
                <h3><a href="../../index.html?facet-correspondent={$model?key}">Briefe von und an {$model?label}</a>: {count($mentions)}</h3>
            </div>
        else
            ()
};

(:~
 : Keep this. This function does the actual lookup in the imported modules.
 :)
declare function api:lookup($name as xs:string, $arity as xs:integer) {
    try {
        function-lookup(xs:QName($name), $arity)
    } catch * {
        ()
    }
};