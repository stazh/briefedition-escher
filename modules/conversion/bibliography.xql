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
        <TEI xml:id="bibliography" type="Bibliographie"> 
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title>Alfred Escher Briefedition: Bibliographie</title>
                    </titleStmt>
                    <publicationStmt>
                        <p>Publication Information</p>
                    </publicationStmt>
                    <sourceDesc>
                        <p>Information about the source</p>
                    </sourceDesc>
                </fileDesc>            
            </teiHeader>
            <standOff>
                <listBibl>
                    {$bibl}
                </listBibl>
            </standOff>
        </TEI>

    return 
            xmldb:store("/db/apps/escher/data/bibliography", 'bibliography.xml', conv:fix-namespace($xml))
};

declare function conv:bibl($type as xs:string) {
    for $entry in doc("/db/apps/escher/data/temp/bibliography.xml")//entry[@type=$type]
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
        {if ($entry/@escheriana = "true") then attribute subtype {'escheriana'} else ()}
        <abbr>{$entry/rs/string()}</abbr>
        <bibl>{conv:transform($entry/bibl/node())}</bibl>
    </bibl>
};

declare function conv:transform($nodes as node()*) {
    for $node in $nodes
    return
        typeswitch($node)
            case element(ref) return
                <ref target="{$node/text()}">{$node/string()}</ref>
            case element(abbr) return
                <choice><abbr>{conv:transform($node/node())}</abbr><expan>{$node/@norm/string()}</expan></choice>
            case element() return
                element { node-name($node) } {
                    $node/@*,
                    conv:transform($node/node())
                }  
            default return
                $node
};

declare function conv:fix-xmlid($id as xs:string) {
    translate($id, " ()'", "-_")
};

conv:main()