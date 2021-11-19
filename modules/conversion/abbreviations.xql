xquery version "3.1";

declare namespace conv="http://alfred-escher.ch/app/transform/people";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function conv:main() {
    let $xml:= 
    <taxonomy xml:id="abbreviations">
        <taxonomy xml:id="secondary">
            {conv:abbr('secondary')}
        </taxonomy>
        <taxonomy xml:id="source">
            {conv:abbr('source')}
        </taxonomy>

    </taxonomy>

    return 
            xmldb:store("/db/apps/escher/data/abbreviations", 'abbreviations.xml', conv:fix-namespace($xml))
};

declare function conv:abbr($type as xs:string) {
    for $entry in collection("/db/apps/escher/data/abbreviations")//*[local-name()=$type || '_abbreviations']/abbreviation
        let $c := conv:abbreviation($entry)
        (: let $file := util:document-name($entry) :)
        return
        $c
            (: xmldb:store("/db/apps/escher/data/commentary", $file, conv:fix-namespace($c)) :)
};

declare function conv:fix-namespace($nodes as node()*) {
    for $node in $nodes
    return
        typeswitch($node)
            case element() return
                element { QName("http://www.tei-c.org/ns/1.0", local-name($node)) } {
                    $node/@*,
                    conv:fix-namespace($node/node())
                }
            default return
                $node
};

 

declare function conv:abbreviation($entry as element(abbreviation)) {
    let $c-id := $entry/abbr/string()
    let $full := $entry/full/string()

    return
        <category>
        <catDesc ana="abbr">{$c-id}</catDesc>
        <catDesc ana="full">{$full}</catDesc>
        </category>
};

declare function conv:fix-xmlid($id as xs:string) {
    translate($id, " ()'", "-_")
};


conv:main()