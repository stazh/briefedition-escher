xquery version "3.1";

declare namespace conv="http://alfred-escher.ch/app/transform/people";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function conv:main() {
    let $places := doc("/db/apps/escher/data/temp/places.xml")/places
    let $records :=
        for $entry in $places/place[@id]
        return
            conv:place($entry, $places)
    let $output :=
        <TEI>
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title>Alfred Escher Briefedition: Ortsdaten</title>
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
                <listPlace>
                {
                    $records
                }
                </listPlace>
            </standOff>
        </TEI>
    return
        xmldb:store("/db/apps/escher/data", "places.xml", conv:fix-namespace($output))
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

declare function conv:links($links) {
    for $link in $links
    return
        <ref target="{$link/url}">{$link/description/node()}</ref>
};

declare function conv:type($place) {
    for $type in $place//links/geo/type
    return
        $type/string()
};

declare function conv:refs($id, $places) {
    for $type in $places//place[.//ref[@target=$id]]
    return
        <placeName type="variant">{$type/name/string()}</placeName>
};

declare function conv:place($place as element(place), $places) {
          <place  xml:id="{conv:fix-xmlid($place/@id)}" n="{$place/@id}" type="{conv:type($place)}">
           <placeName type="main">{$place//name/node()}</placeName>
           {conv:refs($place/@id, $places)}
           {if ($place//name/add) then <placeName type="add">{$place//name/add/node()}</placeName> else ()}
           
           <location>
              <geogFeat>{conv:type($place)}</geogFeat>
              {$place//links/geo}
           </location>
           {
                if (count($place//links/link)) then
                    <desc>{conv:links($place//links/link)}</desc>
                else
                    ()
           }
        </place>
};

declare function conv:fix-xmlid($id as xs:string) {
    translate($id, " ()'", "-_")
};

declare function conv:idno($id, $type) {
    <idno type="{$type}">{$id}</idno>
};

conv:main()