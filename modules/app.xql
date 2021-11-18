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

declare function app:navigation($node as node(), $model as map(*), $type as xs:string) {
    let $context := $model?data//tei:correspDesc/tei:correspContext
    let $next := $context/tei:ref[@type=$type]
    return
        if ($next) then
            <a href="{$next/@target}">{templates:process($node/node(), $model)}</a>
        else
            <div/>
};
