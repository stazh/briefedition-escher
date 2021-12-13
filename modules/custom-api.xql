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
import module namespace pm-config="http://www.tei-c.org/tei-simple/pm-config" at "pm-config.xql";

declare function api:view-bibliography($request as map(*)) {
    app:view-bibliography(<div/>, $request?parameters)
};

declare function api:view-abbreviations($request as map(*)) {
    app:view-abbreviations(<div/>, $request?parameters)
};

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
                "template": "commentary.html",
                "uri": "kontexte/uberblickskommentare/" || $name
            }
            return
                templates:apply($template, vapi:lookup#2, $model, tpu:get-template-config($request))
        else
            error($errors:NOT_FOUND, "Document " || $request?parameters?id || " not found")
};

declare function api:table-of-contents($request as map(*)) {
    let $path := xmldb:decode($request?parameters?id)
    let $doc := config:get-document($path)
    return
        <div>{
            if ($doc//tei:div/tei:div) then
                for $head in $doc//tei:head
                let $level := count($head/ancestor::tei:div)
                where $level > 1 and $level < 4
                return
                    <pb-link hash="{$head/parent::tei:div/@xml:id}" emit="transcription">
                    {
                        $pm-config:web-transform($head, map { "mode": "toc", "root": $head }, $config:default-odd)
                    }
                    </pb-link>
            else
                ()
        }</div>
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
                "template": "person.html",
                "uri": "kontexte/personen/" || $label
            }
            return
                templates:apply($template, vapi:lookup#2, $model, tpu:get-template-config($request))
        else
            error($errors:NOT_FOUND, "Document " || $request?parameters?id || " not found")
};

declare function api:view-letter($request as map(*)) {
    let $id := "B" || xmldb:decode($request?parameters?id)
    let $template := doc($config:app-root || "/templates/pages/escher.html")
    let $model := map {
        "doc": "briefe/" || $id,
        "template": "escher"
    }
    return
        templates:apply($template, vapi:lookup#2, $model, tpu:get-template-config($request))
};

declare function api:view-article($request as map(*)) {
    let $id := xmldb:decode($request?parameters?id)
    let $template := doc($config:app-root || "/templates/pages/article.html")
    let $model := map {
        "doc": $id || '.xml',
        "template": "article"
    }
    return
        templates:apply($template, vapi:lookup#2, $model, tpu:get-template-config($request))
};

declare function api:view-about($request as map(*)) {
    let $id := xmldb:decode($request?parameters?doc)
    let $docid := if (ends-with($id, '.xml')) then $id else $id || '.xml'
    let $template := doc($config:app-root || "/templates/pages/about.html")
    let $title := (doc($config:data-root || "/uber-die-edition/" || $docid)//tei:text//tei:head)[1]
    let $model := map {
        "doc": 'uber-die-edition/' || $docid,
        "template": "about",
        "title": $title,
        "docid": $id,
        "uri": "uber-die-edition/" || $id
    }
    return
        templates:apply($template, vapi:lookup#2, $model, tpu:get-template-config($request))
};

declare function api:people($request as map(*)) {
    let $search := normalize-space($request?parameters?search)
    let $letterParam := $request?parameters?letter
    let $view := $request?parameters?view
    let $sortDir := $request?parameters?dir
    let $limit := $request?parameters?limit
    let $people :=
        if ($view = "correspondents") then
            if ($search) then
                doc($config:data-root || "/people.xml")//tei:listPerson/tei:person[ft:query(., 'name:(' || $search || '*)')][@type="correspondent"]
            else
                doc($config:data-root || "/people.xml")//tei:listPerson/tei:person[@type="correspondent"]
        else
            if ($search) then
                doc($config:data-root || "/people.xml")//tei:listPerson/tei:person[ft:query(., 'name:(' || $search || '*)')]
            else
                doc($config:data-root || "/people.xml")//tei:listPerson/tei:person
    let $byKey := for-each($people, function($person as element()) {
        let $name := $person/tei:persName
        let $label :=
            if ($name/tei:surname) then
                string-join(($name/tei:surname, $name/tei:forename), ", ")
            else
                $name/text()
        let $sortKey :=
            if (starts-with($label, "von ")) then
                substring($label, 5)
            else
                $label
        return
            [lower-case($sortKey), $label, $person]
    })
    let $sorted := api:sort($byKey, $sortDir)
    let $prevQuery := session:get-attribute($config:session-prefix || ".people.query")
    let $letter := 
        if (count($people) < $limit) then 
            "all"
        else if ($letterParam = '' or $prevQuery != $search) then
            substring($sorted[1]?1, 1, 1) => upper-case()
        else
            $letterParam
    let $byLetter :=
        if ($letter = 'all') then
            $sorted
        else
            filter($sorted, function($entry) {
                starts-with($entry?1, lower-case($letter))
            })
    let $split := count($byLetter) idiv 2
    return
        <div class="people-list">
            { session:set-attribute($config:session-prefix || ".people.query", $search) }
            <header title="{$prevQuery}" data-active="{$letter}">
            {
                if (count($people) < $limit) then
                    ()
                else (
                    for $index in 1 to string-length('ABCDEFGHIJKLMNOPQRSTUVWXYZ')
                    let $alpha := substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ', $index, 1)
                    let $hits := count(filter($sorted, function($entry) { starts-with($entry?1, lower-case($alpha))}))
                    where $hits > 0
                    return
                        <a href="#{$alpha}" title="{$hits} Einträge" class="{if ($alpha = $letter) then 'active' else ()}">{$alpha}</a>,
                    <a href="#all" title="{count($sorted)} Einträge" class="{if ($letter = 'all') then 'active' else ()}">All</a>
                )
            }
            </header>

            <div class="list">
                <div>{ api:output-person(subsequence($byLetter, 1, $split + 1), $letter, $view, $search) }</div>
                <div>{ api:output-person(subsequence($byLetter, $split + 2), $letter, $view, $search) }</div>
            </div>
        </div>
};

declare function api:output-person($list, $letter as xs:string, $view as xs:string, $search as xs:string?) {
    for $person in $list
    let $dates := string-join(($person?3/tei:birth, $person?3/tei:death), "–")
    let $letterParam := if ($letter = "all") then substring($person?3/@n, 1, 1) else $letter
    let $params := "letter=" || $letterParam || "&amp;view=" || $view || "&amp;search=" || $search
    return
        <div class="person">
            <a href="{$person?3/@n}?{$params}">{$person?2}</a>
            { if ($dates) then <span class="dates"> ({$dates})</span> else () }
        </div>
};

declare function api:sort($people as array(*)*, $dir as xs:string) {
    let $sorted :=
        sort($people, "?lang=de-DE", function($entry) {
            $entry?1
        })
    return
        if ($dir = "asc") then
            $sorted
        else
            reverse($sorted)
};

declare function api:person-mentions($node as node(), $model as map(*)) {
    let $letters := collection($config:data-root || "/briefe")//tei:text[ft:query(., 'mentioned:"'||$model?key||'"')]
    let $commentaries := collection($config:data-root || "/commentary")//tei:text[ft:query(., 'mentioned:"'||$model?key||'"')]
    let $biographies := doc($config:data-root || "/people.xml")//tei:persName[@key=$model?key]/ancestor::tei:person[@xml:id != $model?key]
    let $titles := doc($config:data-root || "/titles.xml")
    return
        if (count($letters) or count($commentaries) or count($biographies)) then
            <div>
                <h3>Erwähnungen von {$model?label}</h3>
                {
                    if (count($letters) > 0) then
                        <pb-collapse>
                            <div slot="collapse-trigger">
                                <h4>In Briefen: {count($letters)}</h4>
                            </div>
                            <div slot="collapse-content">
                                <ul>
                                {api:letter-list("mentioned", $letters, $titles, $model?key)}
                                </ul>
                            </div>
                        </pb-collapse>
                    else
                        ()
                }

                {
                    if (count($commentaries) > 0) then
                        <pb-collapse>
                            <div slot="collapse-trigger">
                                <h4>In Überblickskommentaren: {count($commentaries)}</h4>
                            </div>
                            <div slot="collapse-content">
                                <ul>
                                    {api:commentary-list($commentaries, $titles)}
                                </ul>
                            </div>
                        </pb-collapse>
                    else
                        ()
                }
                
                {
                    if (count($biographies) > 0) then
                        <pb-collapse>
                            <div slot="collapse-trigger">
                            <h4>In Biographien: {count($biographies)}</h4>
                            </div>
                            <div slot="collapse-content">
                                <ul>
                                    {
                                        for $p in $biographies
                                        return 
                                        <li><a href="{$p/@n}">{$p/@n/string()}</a> | {$p/tei:birth}—{$p/tei:death}</li>
                                    }
                                </ul>
                            </div>
                        </pb-collapse>
                    else
                        ()
                }
            </div>
        else 
            ()
};

declare function api:person-letters($node as node(), $model as map(*)) {
    let $mentions := collection($config:data-root || "/briefe")//tei:text[ft:query(., 'correspondent:"'||$model?key||'"')]
    return
        if (count($mentions) ) then
            let $titles := doc($config:data-root || "/titles.xml")

            return
            <div>
                <h3>Briefe von und an {$model?label}: {count($mentions)}</h3>
                <ul>
                    {api:letter-list("correspondent", $mentions, $titles, $model?key)}
                </ul>
            </div>
        else
            ()
};

declare function api:letter-list($type, $list, $titles, $key) {
    for $doc in subsequence($list, 1, 15)
    let $id := $doc/ancestor::tei:TEI/@xml:id
    return
        <li>
            <a href="../../briefe/B{substring($id, 3)}">
                {$titles/id($id)/string()}
            </a>
        </li>,
    if (count($list) > 15) then
        <li><a href="../../briefe/?facet-{$type}={$key}">... &gt; <pb-i18n key="label.all"/></a></li>
    else
        ()
};

declare function api:commentary-list($list, $titles) {
    for $doc in $list
        let $id := $doc/ancestor::tei:TEI/@xml:id
    return
        <li>
            <a href="../../kontexte/uberblickskommentare/{$id}">
                {$titles/id($id)/string()}
            </a>
        </li>
};

declare function api:breadcrumb-suffix($node as node(), $model as map(*)) {
    $model?title
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