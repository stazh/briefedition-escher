xquery version "3.1";

(: 
 : Module for app-specific template functions
 :
 : Add your own templating functions here, e.g. if you want to extend the template used for showing
 : the browsing view.
 :)
module namespace app="teipublisher.com/app";

import module namespace templates="http://exist-db.org/xquery/html-templating";
import module namespace config="http://www.tei-c.org/tei-simple/config" at "config.xqm";

import module namespace query="http://www.tei-c.org/tei-simple/query" at "../../query.xql";
import module namespace nav="http://www.tei-c.org/tei-simple/navigation" at "../../navigation.xql";
import module namespace tpu="http://www.tei-c.org/tei-publisher/util" at "../util.xql";
import module namespace kwic="http://exist-db.org/xquery/kwic" at "resource:org/exist/xquery/lib/kwic.xql";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare 
    %templates:wrap
function app:counts($node as node(), $model as map(*)) {
    map {
        "letters": count(collection($config:data-root || "/letters")/tei:TEI),
        "people": count(doc($config:data-root || "/people.xml")//tei:person)
    }
};

declare function app:alphabet() {
    let $foo := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     
    for $index in 1 to string-length($foo)
        return substring($foo, $index, 1)
};

declare function app:category-bibliography($type) {
    switch($type)
        case "Escheriana" return "escheriana"
        case "Ungedruckte-Quellen" return "unprinted_source"
        case "Gedruckte-Quellen" return "printed_source"
        case "Zeitungen-und-Zeitschriften" return "newspaper"
        case "Literatur" return "literature"
        case "Websites" return "online"
        case "Archivbestande" return "archive"
        default return "escheriana" 
};

declare function app:active-subcategory($type, $active) {
    if ($type = $active) then " active" else ""
};

declare function app:subcategories-bibliography($node as node(), $model as map(*)) {
    let $type := if ($model?name) then $model?name else 'Escheriana'

    return
    <div>
        <a class="initial {app:active-subcategory('Escheriana', $type)}" 
            href="../Escheriana/Alle" data-template="pages:parse-params">Escheriana</a>        
        <a class="initial {app:active-subcategory('Archivbestande', $type)}" 
            href="../Archivbestande/A" data-template="pages:parse-params">Archivbestände</a>
        <a class="initial {app:active-subcategory('Ungedruckte-Quellen', $type)}" 
            href="../Ungedruckte-Quellen/A" data-template="pages:parse-params">Ungedruckte Quellen</a>         
        <a class="initial {app:active-subcategory('Gedruckte-Quellen', $type)}" 
            href="../Gedruckte-Quellen/A" data-template="pages:parse-params">Gedruckte Quellen</a>
        <a class="initial {app:active-subcategory('Zeitungen-und-Zeitschriften', $type)}" 
            href="../Zeitungen-und-Zeitschriften/A" data-template="pages:parse-params">Zeitungen und Zeitschriften</a>
        <a class="initial {app:active-subcategory('Literatur', $type)}" 
            href="../Literatur/A" data-template="pages:parse-params">Literatur</a>
        <a class="initial {app:active-subcategory('Websites', $type)}" 
            href="../Websites/A" data-template="pages:parse-params">Websites</a> 
    </div>
};

declare function app:view-bibliography($node as node(), $model as map(*)) {
    
    let $type := if ($model?name) then $model?name else 'Archivbestande'
    let $letter := if ($model?letter) then $model?letter else 'A'

    let $category := app:category-bibliography($type)

    let $hits := 
        switch ($category)
            case "escheriana" return
                collection($config:data-root || "/bibliography")//tei:bibl[@subtype="escheriana"]
            default return 
                collection($config:data-root || "/bibliography")/id($category)/tei:bibl
    
    let $matches := 
        switch($letter)
            case "Alle" return 
                $hits
            default return 
                $hits[starts-with(./tei:bibl, $letter)]

    for $group in $matches
        let $initial := upper-case(substring(normalize-space($group/tei:bibl), 1, 1))
        group by $initial 
        order by $initial
        return 
            <div class="bibentry">
                <h3 id="{$initial}">{$initial}</h3>
                <div>
                {
                    for $entry in $group
                    return 
                        <p>{$entry/tei:bibl} [{$entry/tei:abbr}]</p>
                }
                </div>
            </div>
};

declare function app:initial-bibliography($node as node(), $model as map(*)) {
        let $type := if ($model?name) then $model?name else 'Archivbestande'
        let $letter := if ($model?letter) then $model?letter else 'A'

        let $category := app:category-bibliography($type)

        let $letters := app:alphabet()
 
        let $initials :=
                for $i in collection($config:data-root || "/bibliography")/id($category)//tei:bibl
                let $foo := upper-case(substring($i, 1, 1))
                group by $foo
                order by $foo
                return $foo[1]

        return 
            switch ($category) 
                case "escheriana" return ()
                default return 
                    <div>
                        {
                            for $i in $letters
                            let $class := "initial" || (if ($i = $letter) then " active" else "")
                            return
                                if ($i=$initials) then 
                                    <a href="{$i}" class="{$class}">{$i}</a>
                                else
                                    <span class="disabled {$class}">{$i}</span>
                        }
                        <a href="Alle" class="initial"><pb-i18n key="label.all">All</pb-i18n></a>
                    </div>
};

declare 
    %templates:wrap
function app:bibliography-link($node as node(), $model as map(*)) {
    let $type := if ($model?name) then $model?name else 'Escheriana'
    let $letter := if ($model?letter) then $model?letter else if ($type = 'Escheriana') then 'Alle' else 'A'
    return
        map {
            "uri": "kontexte/bibliographie/" || $type || "/" || $letter
        }
};

declare 
    %templates:wrap
function app:abbreviations-link($node as node(), $model as map(*)) {
    let $type := if ($model?name) then $model?name else 'Quellen'
    let $letter := if ($model?letter) then $model?letter else 'A'
    return
        map {
            "uri": "kontexte/abkurzungen/" || $type || "/" || $letter
        }
};

declare function app:subcategories-abbreviations($node as node(), $model as map(*)) {
    let $type := if ($model?name) then $model?name else 'Quellen'

    return
     <div>
        <a class="initial {app:active-subcategory('Quellen', $type)}" 
            href="../Quellen/A" data-template="pages:parse-params">Abkürzungen aus den Quellen</a>        
        <a class="initial {app:active-subcategory('Sekundartexte', $type)}" 
            href="../Sekundartexte/A" data-template="pages:parse-params">Abkürzungen aus Sekundärtexten</a>
    </div>
};
declare function app:initial-abbreviations($node as node(), $model as map(*)) {
        let $type := if ($model?name) then $model?name else 'Quellen'
        let $letter := if ($model?letter) then $model?letter else 'A'

        let $type := 
            switch ($type)
                case "Quellen" return 'source'
                default return 'secondary'

        let $letters := app:alphabet()

        let $initials :=
                for $i in collection($config:data-root || "/abbreviations")/id($type)//tei:catDesc
                let $foo := upper-case(substring($i, 1, 1))
                group by $foo
                order by $foo
                return $foo

        return 
            (
                for $i in $letters      
                    let $class := "initial" || (if ($i = $letter) then " active" else "")
                    return
                        if ($i=$initials) then 
                            <a href="{$i}" class="{$class}">{$i}</a>
                        else
                            <span class="disabled {$class}">{$i}</span>
                    ,
                <a href="other" class="initial">other</a>
            )
};

declare function app:view-abbreviations($node as node(), $model as map(*)) {
    let $type := if ($model?name) then $model?name else 'Quellen'

    let $type := 
        switch ($type)
            case "Quellen" return 'source'
            default return 'secondary'

    let $letter := if ($model?letter) then $model?letter else 'A'

    return 
        <div class="letter">
            <h3>{$letter}</h3>
            <table>
            {
            switch($letter) 
                case "other" return
                    for $entry in collection($config:data-root || "/abbreviations")/id($type)/tei:category[matches(tei:catDesc[@ana='abbr'], '^\W')]
                        return 
                            <tr><td>{$entry/tei:catDesc[@ana='abbr']/string()}</td><td>{$entry/tei:catDesc[@ana='full']/string()}</td></tr>
                default return
                    for $entry in collection($config:data-root || "/abbreviations")/id($type)/tei:category[starts-with(tei:catDesc, $letter)]
                        return 
                            <tr><td>{$entry/tei:catDesc[@ana='abbr']/string()}</td><td>{$entry/tei:catDesc[@ana='full']/string()}</td></tr>
            }
            </table>
        </div>
};


declare function app:search($request as map(*)) {
    (:If there is no query string, fill up the map with existing values:)
    if (empty($request?parameters?query))
    then
        app:show-hits($request, session:get-attribute($config:session-prefix || ".hits"), session:get-attribute($config:session-prefix || ".docs"))
    else
        (:Otherwise, perform the query.:)
        (: Here the actual query commences. This is split into two parts, the first for a Lucene query and the second for an ngram query. :)
        (:The query passed to a Luecene query in ft:query is an XML element <query> containing one or two <bool>. The <bool> contain the original query and the transliterated query, as indicated by the user in $query-scripts.:)
        let $hitsAll :=
                (:If the $query-scope is narrow, query the elements immediately below the lowest div in tei:text and the four major element below tei:teiHeader.:)
                for $hit in query:query-default($request?parameters?field, $request?parameters?query, $request?parameters?doc, ())
                order by ft:score($hit) descending
                return $hit
        let $hitCount := count($hitsAll)
        let $hits := if ($hitCount > 1000) then subsequence($hitsAll, 1, 1000) else $hitsAll
        (:Store the result in the session.:)
        let $store := (
            session:set-attribute($config:session-prefix || ".hits", $hitsAll),
            session:set-attribute($config:session-prefix || ".hitCount", $hitCount),
            session:set-attribute($config:session-prefix || ".query", $request?parameters?query),
            session:set-attribute($config:session-prefix || ".field", $request?parameters?field),
            session:set-attribute($config:session-prefix || ".docs", $request?parameters?doc)
        )
        return
            app:show-hits($request, $hits, $request?parameters?doc)
};

declare %private function app:show-hits($request as map(*), $hits as item()*, $docs as xs:string*) {
    response:set-header("pb-total", xs:string(count($hits))),
    response:set-header("pb-start", xs:string($request?parameters?start)),
    for $hit at $p in subsequence($hits, $request?parameters?start, $request?parameters?per-page)
    let $config := tpu:parse-pi(root($hit), $request?parameters?view)
    let $letterId := "B" || substring(root($hit)/descendant-or-self::tei:TEI/@xml:id, 3)
  
    let $parent := query:get-parent-section($config, $hit)
    let $parent-id := config:get-identifier($parent)
    let $parent-id := if (exists($docs)) then replace($parent-id, "^.*?([^/]*)$", "$1") else $parent-id
    let $parent-id := if (util:collection-name($parent-id) = 'letters') then $letterId else $parent-id

    let $uri := 
        if (starts-with($parent-id, 'B')) then
            'briefe/'
        else
            ()

    let $div := query:get-current($config, $parent)
    let $expanded := util:expand($hit, "add-exist-id=all")
    let $docId := config:get-identifier($div)
    return
        <paper-card>
            <header>
                <div class="count">{$request?parameters?start + $p - 1}</div>
                { query:get-breadcrumbs($config, $hit, $uri || $parent-id) }
            </header>
            <div class="matches">
            {
                for $match in subsequence($expanded//exist:match, 1, 5)
                let $matchId := $match/../@exist:id
                let $docLink :=
                    if ($config?view = "page") then
                        (: first check if there's a pb in the expanded section before the match :)
                        let $pbBefore := $match/preceding::tei:pb[1]
                        return
                            if ($pbBefore) then
                                $pbBefore/@exist:id
                            else
                                (: no: locate the element containing the match in the source document :)
                                let $contextNode := util:node-by-id($hit, $matchId)
                                (: and get the pb preceding it :)
                                let $page := $contextNode/preceding::tei:pb[1]
                                return
                                    if ($page) then
                                        util:node-id($page)
                                    else
                                        util:node-id($div)
                    else
                        (: Check if the document has sections, otherwise don't pass root :)
                        if (nav:get-section-for-node($config, $div)) then util:node-id($div) else ()
                let $config := <config width="60" table="no" link="{$uri}{$parent-id}?action=search&amp;view={$config?view}&amp;odd={$config?odd}#{$matchId}"/>
                return
                    kwic:get-summary($expanded, $match, $config)
            }
            </div>
        </paper-card>
};

