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

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare 
    %templates:wrap
function app:counts($node as node(), $model as map(*)) {
    map {
        "letters": count(collection($config:data-root || "/letters")/tei:TEI),
        "people": count(doc($config:data-root || "/people.xml")//tei:person)
    }
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

declare function app:active-bibliography($type, $active) {
    if ($type = $active) then " active" else ""
};

declare function app:subcategories-bibliography($node as node(), $model as map(*)) {
    let $type := if ($model?name) then $model?name else 'Escheriana'

    return
     <div>
        <a class="initial {app:active-bibliography('Escheriana', $type)}" 
            href="../Escheriana/Alle" data-template="pages:parse-params">Escheriana</a>        
        <a class="initial {app:active-bibliography('Archivbestande', $type)}" 
            href="../Archivbestande/A" data-template="pages:parse-params">Archivbestände</a>
        <a class="initial {app:active-bibliography('Ungedruckte-Quellen', $type)}" 
            href="../Ungedruckte-Quellen/A" data-template="pages:parse-params">Ungedruckte Quellen</a>         
        <a class="initial {app:active-bibliography('Gedruckte-Quellen', $type)}" 
            href="../Gedruckte-Quellen/A" data-template="pages:parse-params">Gedruckte Quellen</a>
        <a class="initial {app:active-bibliography('Zeitungen-und-Zeitschriften', $type)}" 
            href="../Zeitungen-und-Zeitschriften/A" data-template="pages:parse-params">Zeitungen und Zeitschriften</a>
        <a class="initial {app:active-bibliography('Literatur', $type)}" 
            href="../Literatur/A" data-template="pages:parse-params">Literatur</a>
        <a class="initial {app:active-bibliography('Websites', $type)}" 
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

        let $foo := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        let $letters := 
            for $index in 1 to string-length($foo)
                return substring($foo, $index, 1)

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

declare function app:initial-abbreviations($node as node(), $model as map(*)) {
        let $type := if ($model?name) then $model?name else 'Quellen'
        let $type := 
            switch ($type)
                case "Quellen" return 'source'
                default return 'secondary'

        let $foo := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        let $letters := 
            for $index in 1 to string-length($foo)
                return substring($foo, $index, 1)

        let $initials :=
                for $i in collection($config:data-root || "/abbreviations")/id($type)//tei:catDesc
                let $foo := upper-case(substring($i, 1, 1))
                group by $foo
                order by $foo
                return $foo

        return 
            (for $i in $letters      
                return
                    <a href="{$i}" class="initial">{$i}</a>,
            <a href="other" class="initial">other</a>)
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
