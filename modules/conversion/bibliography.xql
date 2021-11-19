xquery version "3.1";

declare namespace conv="http://alfred-escher.ch/app/transform/people";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function conv:main() {

    let $types := ("unprinted_source", "printed_source", "newspaper", "literature", "online", "archive")
    let $bibl:= 
        for $i in $types return
            <listBibl xml:id="{$i}">
                {conv:bibl($i)}
            </listBibl>

    let $xml :=
        <standOff>
            <listBibl>
            {$bibl}
            </listBibl>
        </standOff>
    return 
            xmldb:store("/db/apps/escher/data/bibliography", 'bibliography.xml', conv:fix-namespace($xml))
};

declare function conv:bibl($type as xs:string) {
    for $entry in collection("/db/apps/escher/data/bibliography")//entry[@type=$type]
        return conv:entry($entry)
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

declare function conv:entry($entry as element()) {
    <bibl xml:id="{$entry/@id}" type="{$entry/@type}">
        <abbr>{$entry/rs/string()}</abbr>
        <bibl>{$entry/bibl/string()}</bibl>
    </bibl>
};

declare function conv:fix-xmlid($id as xs:string) {
    translate($id, " ()'", "-_")
};

conv:main()