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

(: Unused, now generated from ODD :)
declare function app:navigation($node as node(), $model as map(*), $type as xs:string) {
    let $context := $model?data//tei:correspDesc/tei:correspContext
    let $next := $context/tei:ref[@type=$type]
    return
        if ($next) then
            <pb-link path="letters/{$next/@target}" emit="transcription">{templates:process($node/node(), $model)}</pb-link>
            (: <a href="{$next/@target}">{templates:process($node/node(), $model)}</a> :)
        else
            <div/>
};

declare function app:view-bibliography($node as node(), $model as map(*)) {
    
    let $type := if ($model?name) then $model?name else 'Archivbestande'
    let $letter := if ($model?letter) then $model?letter else 'A'

    let $category := switch($type)
        case "Escheriana" return "escheriana"
        case "Ungedruckte-Quellen" return "unprinted_source"
        case "Gedruckte-Quellen" return "printed_source"
        case "Zeitungen-und-Zeitschriften" return "newspaper"
        case "Literatur" return "literature"
        case "Websites" return "online"
        case "Archivbestande" return "archive"
        default return "escheriana"
        
    
    let $matches := 
        switch($letter)
            case "all" return 
                collection($config:data-root || "/bibliography")/id($category)/tei:bibl
            default return 
                collection($config:data-root || "/bibliography")/id($category)/tei:bibl[starts-with(./tei:bibl, $letter)]


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
        
        let $category := switch($type)
                case "Escheriana" return "escheriana"
                case "Ungedruckte-Quellen" return "unprinted_source"
                case "Gedruckte-Quellen" return "printed_source"
                case "Zeitungen-und-Zeitschriften" return "newspaper"
                case "Literatur" return "literature"
                case "Websites" return "online"
                case "Archivbestande" return "archive"
                default return "escheriana"
        

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

            <div>
                <h1>Bibliographie: {$type}</h1>
                {
                    for $i in $initials[.=$letters]
                        return
                    <a href="{$i}" class="initial">{$i}</a>
                }
                <a href="all" class="initial">all</a>
            </div>
            
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
