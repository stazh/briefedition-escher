xquery version "3.1";

declare namespace conv="http://alfred-escher.ch/app/transform/people";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function conv:main() {
    let $records :=
        for $person in collection("/db/apps/people")/biography
        return
            conv:person($person)
    let $output :=
        <TEI>
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title>Alfred Escher Briefedition: Personendaten</title>
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
                <listPerson>
                {
                    $records
                }
                </listPerson>
            </standOff>
        </TEI>
    return
        xmldb:store("/db/apps/escher/data", "people.xml", conv:fix-namespace($output))
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

declare function conv:person($person as element(biography)) {
    let $meta := $person/metadata
    return
        <person xml:id="{conv:fix-xmlid($person/@id)}" n="{$person/@id}">
            <persName>
                <forename>{$meta/name/firstname/string()}</forename>
                <surname>{$meta/name/lastname/string()}</surname>
            </persName>
            { conv:date($meta/age) }
            { 
                if ($person/body/*) then
                    <note type="bio">
                    { conv:body($person/body/*) }
                    </note>
                else
                    ()
            }
            {
                $meta/links/pnd[. != ""]/string() ! conv:idno(., "gnd"),
                $meta/links/link/url[. != ""]/string() ! conv:idno(., "URI")
            }
            {
                $person/foot/references ! <bibl>{conv:body(./node())}</bibl>
            }
        </person>
};

declare function conv:fix-xmlid($id as xs:string) {
    translate($id, " ()'", "-_")
};

declare function conv:idno($id, $type) {
    <idno type="{$type}">{$id}</idno>
};

declare function conv:date($age) {
    let $elems := ("birth", "death")
    for $part at $pos in tokenize($age, '–')
    return
        element { xs:QName($elems[$pos]) } {
            $part
        }
};

declare function conv:body($nodes as node()*) {
    for $node in $nodes
    return
        typeswitch($node)
            case element(idx) return
                if ($node/@type = "person") then
                    <persName key="{$node/@norm}">{conv:body($node/node())}</persName>
                else
                    <placeName key="{$node/@norm}">{conv:body($node/node())}</placeName>
            case element(abbr) return
                <choice>
                    <abbr>{conv:body($node/node())}</abbr>
                    <expan>{$node/@norm/string()}</expan>
                </choice>
            case element(d) return
                let $tokens := tokenize($node/@norm, '\.')
                let $norm := string-join(reverse($tokens), '-')
                return
                    <date when="{$norm}">{conv:body($node/node())}</date>
            case element(ref) return
                switch($node/@type)
                    case "www" return
                        if ($node/@target and $node/@target != "") then
                            <ref target="{$node/@target}">{conv:body($node/node())}</ref>
                        else
                            conv:body($node/node())
                    case "lit" return
                        <ref type="lit">{conv:body($node/node())}</ref>
                    case "sum" return
                        <ref type="sum" target="{$node/@target}">{conv:body($node/node())}</ref>
                    default return
                        conv:body($node/node())
            case element() return
                element { node-name($node) } {
                    $node/@*,
                    conv:body($node/node())
                }
            default return
                $node
};

conv:main()