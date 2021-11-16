xquery version "3.1";

(:~
 : Extension functions for SSRQ.
 :)
module namespace pmf="http://www.tei-c.org/tei-simple/xquery/functions/escher-web";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace html="http://www.tei-c.org/tei-simple/xquery/functions";

declare function pmf:init($config as map(*), $node as node(), $class as xs:string+, $content) {
    let $id := root($node)/tei:TEI/@xml:id
    let $newConfig := map:merge((
        $config,
        map {
            "parameters": map:merge((
                $config?parameters,
                map {
                    "regions": collection("/db/apps/escher/data/regions")/mappingtable/doc[@id=$id]
                }
            ))
        }
    ))
    return
        html:apply-children($newConfig, $node, $content)
};

declare function pmf:facsimiles($config as map(*), $node as node(), $class as xs:string+, $content) {
    for $map in $config?parameters?regions
    return
        <pb-facs-link facs="{$map/@image}"></pb-facs-link>
};

declare function pmf:line-break($config as map(*), $node as node(), $class as xs:string+, $content) {
    let $pageId := replace($node/@xml:id, '^p(\d+)-.*$', '$1')
    let $map := $config?parameters?regions[@n=$pageId]
    return (
        if ($node/@break = 'no') then
            <span class="hyphen">-</span>
        else
            (),
        <br class="{$class}" data-image="{$map/@image}" data-coords="{$map/area[@target=$node/@xml:id]/@coords}"/>,
        if ($node/@break = 'no') then
            ()
        else
            text { ' ' }
    )
};