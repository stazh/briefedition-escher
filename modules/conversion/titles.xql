xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";

let $output :=
    document {
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
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
            <text>
                <body>
                    <div xmlns="http://www.tei-c.org/ns/1.0">
                    {
                        for $doc in collection("/db/apps/escher/data/briefe")
                        let $title := $doc//titleStmt/title
                        return
                            <title>
                            {
                                attribute xml:id { $doc/TEI/@xml:id },
                                $title/node()
                            }
                            </title>,
                        for $doc in collection("/db/apps/escher/data/commentary")
                        let $title := $doc//titleStmt/title
                        return (
                            <title>
                            {
                                attribute xml:id { $doc/TEI/@xml:id },
                                $title/node()
                            }
                            </title>,
                            for $head in $doc//div/head
                            let $id := $head/parent::div/@xml:id
                            let $hash := replace($id, '^.*?_d([^_]+)$', '$1')
                            return
                                <title>
                                {
                                    attribute xml:id { $id },
                                    string-join((
                                        if (count($head/ancestor::div) = 1 and count($doc//body/div) = 1) then
                                            ()
                                        else
                                            $title,
                                        if ($head//text()) then
                                            $head/string()
                                        else
                                            'Kapitel ' || $hash
                                    ), ', ')
                                }
                                </title>,
                            for $para in $doc//p[@xml:id]
                            let $id := $para/@xml:id
                            let $hash := replace($id, '^.*?_p([^_]+)$', '$1')
                            return
                                <title>
                                {
                                    attribute xml:id { $id },
                                    string-join((
                                        $title,
                                        'Absatz ' || $hash
                                    ), ', ')
                                }
                                </title>
                        )
                    }
                    </div>
                </body>
            </text>
        </TEI>
    }
return
    xmldb:store("/db/apps/escher/data", "titles.xml", $output)