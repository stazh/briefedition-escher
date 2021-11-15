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
import module namespace app="teipublisher.com/app" at "app.xql";
import module namespace config="http://www.tei-c.org/tei-simple/config" at "config.xqm";

declare function api:people($request as map(*)) {
    let $search := $request?parameters?search
    let $sortDir := $request?parameters?dir
    let $limit := $request?parameters?limit
    let $start := $request?parameters?start
    let $filter := $request?parameters?filter
    let $people := 
        if ($search) then
            doc($config:data-root || "/people.xml")//tei:listPerson/tei:person[ft:query(., 'name:' || $search)]
        else
            doc($config:data-root || "/people.xml")//tei:listPerson/tei:person
    let $sorted := api:sort($people, $sortDir)
    let $subset := subsequence($people, $start, $limit)
    return (
        session:set-attribute($config:session-prefix || ".hits", $people),
        session:set-attribute($config:session-prefix || ".hitCount", count($people)),
        map {
            "count": count($people),
            "results":
                array {
                    for $person in $subset
                    let $name := $person/tei:persName
                    return
                        map {
                            "id": $person/@xml:id/string(),
                            "name": 
                                if ($name/tei:surname) then
                                    string-join(($name/tei:surname, $name/tei:forename), ", ")
                                else
                                    $name/string(),
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