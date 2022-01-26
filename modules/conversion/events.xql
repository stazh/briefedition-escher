xquery version "3.1";

declare namespace conv="http://alfred-escher.ch/app/transform/people";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function conv:main() {
    let $events := doc("/db/apps/escher/data/temp/events.xml")/events
    let $records :=
        for $entry in $events/event[@id]
        return
            conv:event($entry, $events)
    let $output :=
        <TEI>
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title>Alfred Escher Briefedition: Chronologie</title>
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
                <listEvent>
                {
                    $records
                }
                </listEvent>
            </standOff>
        </TEI>
    return
        xmldb:store("/db/apps/escher/data", "events.xml", conv:fix-namespace($output))
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


declare function conv:event($event as element(event), $events) {
    <event xml:id="{$event/@id}" when="{$event//date/@norm}">
        <head>{$event/head/text()}</head>
        <p>{$event/body/text()}</p>
        <bibl>
            <abbr>{$event/metadata/sources/text()}</abbr>
            <note>{$event/metadata/comment/text()}</note>
        </bibl>
    </event>    
};

conv:main()