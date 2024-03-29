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
import module namespace dapi="http://teipublisher.com/api/documents" at "lib/api/document.xql";
import module namespace errors = "http://exist-db.org/xquery/router/errors";
import module namespace tpu="http://www.tei-c.org/tei-publisher/util" at "lib/util.xql";
import module namespace pm-config="http://www.tei-c.org/tei-simple/pm-config" at "pm-config.xql";

declare function api:timeline($request as map(*)) {
    let $entries := session:get-attribute($config:session-prefix || '.hits')
    let $datedEntries := filter($entries, function($entry) {
        if (ft:field($entry, "type") = "Brief") then
            let $date := ft:field($entry, "date", "xs:date")
            return
                exists($date) and year-from-date($date) != 1000
        else
            ()
    })
    let $undatedEntries := $entries except $datedEntries
    return
        map:merge((
            for $entry in $datedEntries
            group by $date := ft:field($entry, "date", "xs:date")
            return
                map:entry(format-date($date, "[Y0001]-[M01]-[D01]"), map {
                    "count": count($entry),
                    "info": api:corresp-titles($entry)
                }),
            if ($undatedEntries) then
                map:entry("?", map {
                    "count": count($undatedEntries),
                    "info": api:corresp-titles($undatedEntries)
                })
            else
                ()
        ))
};

declare function api:corresp-timeline($request as map(*)) {
    let $id := xmldb:decode($request?parameters?id)
    let $timeline := id("K_" || $id, doc($config:data-root || "/timeline.xml"))
    let $entries := $timeline/date
    let $datedEntries := filter($entries, function($entry) {
        let $date := $entry/@when/xs:date(.)
        return
            exists($date) and year-from-date($date) != 1000
    })
    let $undatedEntries := $entries except $datedEntries
    return
        map:merge((
            for $entry in $datedEntries
            return
                map:entry($entry/@when/string(), map {
                    "count": count($entry/ref),
                    "info": api:corresp-titles($entry/ref)
                }),
            if ($undatedEntries) then
                map:entry("?", map {
                    "count": count($undatedEntries),
                    "info": api:corresp-titles($undatedEntries/ref)
                })
            else
                ()
        ))
};

declare function api:corresp-titles($refs as element()*) {
    if (count($refs) < 6) then
        array {
            for $ref in $refs
            let $xmlId :=
                if ($ref instance of element(ref)) then
                    $ref/@target
                else
                    root($ref)/tei:TEI/@xml:id
            let $id := replace($xmlId, "^K_(.*)$", "B$1")
            return
                <a href="{$config:context-path}/briefe/{$id}" part="tooltip-link">{id($xmlId, doc($config:data-root || "/titles.xml"))/string()}</a>
        }
    else
        []
};

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
    let $person := doc($config:data-root || "/people/people.xml")//tei:listPerson/tei:person[@n = $name]
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
                "doc": $config:data-root || "/people/people.xml",
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
        "id": xmldb:decode($request?parameters?id),
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
    let $letterParam := $request?parameters?category
    let $view := $request?parameters?view
    let $sortDir := $request?parameters?dir
    let $limit := $request?parameters?limit
    let $people :=
        if ($view = "correspondents") then
            if ($search and $search != '') then
                doc($config:data-root || "/people/people.xml")//tei:listPerson/tei:person[ft:query(., 'name:(' || $search || '*)')][@type="correspondent"]
            else
                doc($config:data-root || "/people/people.xml")//tei:listPerson/tei:person[@type="correspondent"]
        else
            if ($search and $search != '') then
                doc($config:data-root || "/people/people.xml")//tei:listPerson/tei:person[ft:query(., 'name:(' || $search || '*)')]
            else
                doc($config:data-root || "/people/people.xml")//tei:listPerson/tei:person
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
    let $letter := 
        if (count($people) < $limit) then 
            "Alle"
        else if ($letterParam = '') then
            substring($sorted[1]?1, 1, 1) => upper-case()
        else
            $letterParam
    let $byLetter :=
        if ($letter = 'Alle') then
            $sorted
        else
            filter($sorted, function($entry) {
                starts-with($entry?1, lower-case($letter))
            })
    return
        map {
            "items": api:output-person($byLetter, $letter, $view, $search),
            "categories":
                if (count($people) < $limit) then
                    []
                else array {
                    for $index in 1 to string-length('ABCDEFGHIJKLMNOPQRSTUVWXYZ')
                    let $alpha := substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ', $index, 1)
                    let $hits := count(filter($sorted, function($entry) { starts-with($entry?1, lower-case($alpha))}))
                    where $hits > 0
                    return
                        map {
                            "category": $alpha,
                            "count": $hits
                        },
                    map {
                        "category": "Alle",
                        "count": count($sorted)
                    }
                }
        }
};

declare function api:output-person($list, $letter as xs:string, $view as xs:string, $search as xs:string?) {
    array {
        for $person in $list
        let $dates := string-join(($person?3/tei:birth, $person?3/tei:death), "–")
        let $letterParam := if ($letter = "Alle") then substring($person?3/@n, 1, 1) else $letter
        let $params := "category=" || $letterParam || "&amp;view=" || $view || "&amp;search=" || $search
        return
            <span>
                <a href="{$person?3/@n}?{$params}">{$person?2}</a>
                { if ($dates) then <span class="dates"> ({$dates})</span> else () }
            </span>
    }
};
declare function api:places-all($request as map(*)) {
    let $places := doc($config:data-root || "/places/places.xml")//tei:listPlace/tei:place
    return 
        array { 
            for $place in $places
                let $tokenized := tokenize($place/tei:location/tei:geo)
                return 
                    map {
                        "latitude":$tokenized[1],
                        "longitude":$tokenized[2],
                        "label":$place/@n/string()
                    }
            }        
};

declare function api:places($request as map(*)) {
    let $search := normalize-space($request?parameters?search)
    let $letterParam := $request?parameters?category
    let $limit := $request?parameters?limit
    let $places :=
        if ($search and $search != '') then
            doc($config:data-root || "/places/places.xml")//tei:listPlace/tei:place[ft:query(., 'lname:(' || $search || '*)')]
        else
            doc($config:data-root || "/places/places.xml")//tei:listPlace/tei:place
    let $sorted := sort($places, "?lang=de-DE", function($place) { lower-case($place/@n) })
    let $letter := 
        if (count($places) < $limit) then 
            "Alle"
        else if ($letterParam = '') then
            substring($sorted[1], 1, 1) => upper-case()
        else
            $letterParam
    let $byLetter :=
        if ($letter = 'Alle') then
            $sorted
        else
            filter($sorted, function($entry) {
                starts-with(lower-case($entry/@n), lower-case($letter))
            })
    return
        map {
            "items": api:output-place($byLetter, $letter, $search),
            "categories":
                if (count($places) < $limit) then
                    []
                else array {
                    for $index in 1 to string-length('ABCDEFGHIJKLMNOPQRSTUVWXYZ')
                    let $alpha := substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ', $index, 1)
                    let $hits := count(filter($sorted, function($entry) { starts-with(lower-case($entry/@n), lower-case($alpha))}))
                    where $hits > 0
                    return
                        map {
                            "category": $alpha,
                            "count": $hits
                        },
                    map {
                        "category": "Alle",
                        "count": count($sorted)
                    }
                }
        }
};

declare function api:output-place($list, $category as xs:string, $search as xs:string?) {
    array {
        for $place in $list
        let $categoryParam := if ($category = "all") then substring($place/@n, 1, 1) else $category
        let $params := "category=" || $categoryParam || "&amp;search=" || $search
        let $label := $place/@n/string()
        let $coords := tokenize($place/tei:location/tei:geo)
        return
            <span class="place">
                <a href="{$label}?{$params}">{$label}</a>
                <pb-geolocation latitude="{$coords[1]}" longitude="{$coords[2]}" label="{$label}" emit="map" event="click">
                    { if ($place/@type != 'approximate') then attribute zoom { 9 } else () }
                    <iron-icon icon="maps:map"></iron-icon>
                </pb-geolocation>
            </span>
    }
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

declare function api:place-link($node as node(), $model as map(*) ) {
    let $refs := doc($config:data-root || "/places/places.xml")//tei:place[@n = $model?key]//tei:ref 
        where $refs
    return     
        <div>
            <h3>Externe Links</h3>
            <ul>{
                for $ref in $refs
                    return
                        <li><a href="{$ref/@target/string()}" target="_blank">{$ref/text()}</a></li>
            }</ul>
        </div>
};

declare %templates:default("type", "person") 
function api:person-mentions($node as node(), $model as map(*), $type as xs:string) {
    let $letters := if($type = "person") 
                    then ( 
                        collection($config:data-root || "/briefe")//tei:text[ft:query(., 'mentioned:"'||$model?key||'"')] 
                    )else( 
                        collection($config:data-root || "/briefe")//tei:text[.//tei:placeName/@key = $model?key]
                    )
    let $commentaries := if($type = "person") 
                    then ( 
                        collection($config:data-root || "/commentary")//tei:text[ft:query(., 'mentioned:"'||$model?key||'"')]
                    ) else (  
                        collection($config:data-root || "/commentary")//tei:text[.//tei:placeName/@key = $model?key]
                    )
    let $biographies := if($type = "person") 
                        then ( 
                            doc($config:data-root || "/people/people.xml")//tei:persName[@key=$model?key]/ancestor::tei:person[@xml:id != $model?key]
                        ) else (  
                            doc($config:data-root || "/people/people.xml")//tei:person[.//tei:placeName/@key = $model?key]
                        )
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
                                {api:letter-list(if($type="person") then("mentioned") else ("place"), $letters, $titles, $model?key)}
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
                                        <li><a href="../personen/{$p/@n}">{$p/@n/string()}</a> | {$p/tei:birth}—{$p/tei:death}</li>
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

declare function api:html($request as map(*)) {
    let $doc := xmldb:decode($request?parameters?id)
    return
        if ($doc) then
            let $xml := config:get-document($doc)
            return
                if (exists($xml)) then
                    let $config := tpu:parse-pi(root($xml), ())
                    let $title :=
                        $pm-config:web-transform(
                            $xml//tei:teiHeader//tei:title,
                            map { "root": $xml, "view": "metadata", "webcomponents": 7},
                            $config?odd
                        )
                    let $content :=
                        $pm-config:web-transform(
                            $xml//tei:text,
                            map { "root": $xml, "webcomponents": 7 },
                            $config?odd
                        )
                    let $locales := "resources/i18n/{{ns}}/{{lng}}.json"
                    let $page :=
                            <html>
                                <head>
                                    <meta charset="utf-8"/>
                                    <link rel="stylesheet" type="text/css" href="resources/css/theme.css"/>
                                    <link rel="stylesheet" type="text/css" href="resources/css/escher-theme.css"/>
                                </head>
                                <body class="printPreview">
                                    <paper-button id="closePage" class="hidden-print" onclick="window.close()" title="Seite schließen">
                                        <paper-icon-button icon="close"></paper-icon-button>
                                        Seite schließen
                                    </paper-button>
                                    <paper-button id="printPage" class="hidden-print" onclick="window.print()" title="Seite drucken">
                                        <paper-icon-button icon="print"></paper-icon-button>
                                        Seite drucken
                                    </paper-button>

                                    <pb-page unresolved="unresolved" locales="{$locales}" locale-fallback-ns="app" require-language="require-language" api-version="1.0.0">
                                        <h2 class="letter-title">
                                            { $title }
                                        </h2>
                                            { $content }
                                    </pb-page>
                                </body>
                            </html>
                    return
                        dapi:postprocess($page, (), $config?odd, $config:context-path || "/", true())
                else
                    error($errors:NOT_FOUND, "Document " || $doc || " not found")
        else
            error($errors:BAD_REQUEST, "No document specified")
};
