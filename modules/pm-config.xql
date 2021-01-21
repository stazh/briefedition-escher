
xquery version "3.1";

module namespace pm-config="http://www.tei-c.org/tei-simple/pm-config";

import module namespace pm-escher-web="http://www.tei-c.org/pm/models/escher/web/module" at "../transform/escher-web-module.xql";
import module namespace pm-escher-print="http://www.tei-c.org/pm/models/escher/fo/module" at "../transform/escher-print-module.xql";
import module namespace pm-escher-latex="http://www.tei-c.org/pm/models/escher/latex/module" at "../transform/escher-latex-module.xql";
import module namespace pm-escher-epub="http://www.tei-c.org/pm/models/escher/epub/module" at "../transform/escher-epub-module.xql";
import module namespace pm-docx-tei="http://www.tei-c.org/pm/models/docx/tei/module" at "../transform/docx-tei-module.xql";
import module namespace pm-docbook-web="http://www.tei-c.org/pm/models/docbook/web/module" at "../transform/docbook-web-module.xql";
import module namespace pm-docbook-print="http://www.tei-c.org/pm/models/docbook/fo/module" at "../transform/docbook-print-module.xql";
import module namespace pm-docbook-latex="http://www.tei-c.org/pm/models/docbook/latex/module" at "../transform/docbook-latex-module.xql";
import module namespace pm-docbook-epub="http://www.tei-c.org/pm/models/docbook/epub/module" at "../transform/docbook-epub-module.xql";

declare variable $pm-config:web-transform := function($xml as node()*, $parameters as map(*)?, $odd as xs:string?) {
    switch ($odd)
    case "escher.odd" return pm-escher-web:transform($xml, $parameters)
case "docbook.odd" return pm-docbook-web:transform($xml, $parameters)
    default return pm-escher-web:transform($xml, $parameters)
            
    
};
            


declare variable $pm-config:print-transform := function($xml as node()*, $parameters as map(*)?, $odd as xs:string?) {
    switch ($odd)
    case "escher.odd" return pm-escher-print:transform($xml, $parameters)
case "docbook.odd" return pm-docbook-print:transform($xml, $parameters)
    default return pm-escher-print:transform($xml, $parameters)
            
    
};
            


declare variable $pm-config:latex-transform := function($xml as node()*, $parameters as map(*)?, $odd as xs:string?) {
    switch ($odd)
    case "escher.odd" return pm-escher-latex:transform($xml, $parameters)
case "docbook.odd" return pm-docbook-latex:transform($xml, $parameters)
    default return pm-escher-latex:transform($xml, $parameters)
            
    
};
            


declare variable $pm-config:epub-transform := function($xml as node()*, $parameters as map(*)?, $odd as xs:string?) {
    switch ($odd)
    case "escher.odd" return pm-escher-epub:transform($xml, $parameters)
case "docbook.odd" return pm-docbook-epub:transform($xml, $parameters)
    default return pm-escher-epub:transform($xml, $parameters)
            
    
};
            


declare variable $pm-config:tei-transform := function($xml as node()*, $parameters as map(*)?, $odd as xs:string?) {
    switch ($odd)
    case "docx.odd" return pm-docx-tei:transform($xml, $parameters)
    default return error(QName("http://www.tei-c.org/tei-simple/pm-config", "error"), "No default ODD found for output mode tei")
            
    
};
            
    