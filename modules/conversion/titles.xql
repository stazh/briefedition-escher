xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";

let $output :=
    document {
        <div xmlns="http://www.tei-c.org/ns/1.0">
        {
            for $doc in (collection("/db/apps/escher/data/letters"), collection("/db/apps/escher/data/commentary"))
            let $title := $doc//titleStmt/title
            return
                <title>
                {
                    attribute xml:id { $doc/TEI/@xml:id },
                    $title/node()
                }
                </title>
        }
        </div>
    }
return
    xmldb:store("/db/apps/escher/data", "titles.xml", $output)