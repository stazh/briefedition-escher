xquery version "3.1";

declare namespace conv="http://alfred-escher.ch/app/transform/people";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function conv:main() {
    for $entry in collection("/db/apps/escher/data/commentary")/commentary
        let $c := conv:commentary($entry)
        let $file := util:document-name($entry)
        return
            xmldb:store("/db/apps/escher/data/commentary", $file, conv:fix-namespace($c))
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

declare function conv:commentary($entry as element(commentary)) {
    let $c-id := $entry/@id/string()
    let $meta := $entry/metadata

    let $title := $meta/title/string()
    let $author := $meta/author/string()

    let $v-title := $meta/source/volume_title/string()
    let $v-short-title := $meta/source/short_title/string()
    let $v-page := $meta/source/page/string()
    let $v-volume := "V" || $meta/source/volume/string()

    let $description := $meta/description/string()

    let $header := 
  <teiHeader>
      <fileDesc>
         <titleStmt>
            <title>{$title}</title>
            <author>{$author}</author>
         </titleStmt>
         <publicationStmt>
            <p>Publication Information</p>
         </publicationStmt>
         <sourceDesc>
            <bibl>
               <title>{$v-title}</title>
               <title type="short">{$v-short-title}</title>
               <ref type="volume" target="{$v-volume}">{$v-page}</ref>
            </bibl>
         </sourceDesc>
      </fileDesc>
     <profileDesc>
        <textClass>
           <keywords>
              <term>{$description}</term>
           </keywords>
        </textClass>
     </profileDesc>
     <revisionDesc>
        <listChange>
        {
            for $c in $meta/revision/change
                return
                    $c
        }
        </listChange>
     </revisionDesc>
  </teiHeader>

    let $body := conv:body($entry/body)

    return
        <TEI xml:id="{$c-id}" type="Überblickskommentar">
          {$header}
            <text>
                {$body}
            </text>
        </TEI>
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
            case element(com) return
                    <note type="com" xml:id="{$node/@id}">{conv:body($node/node())}</note>
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

            (: 
            "letter", "www", "lit", "telegram", "kbp", "kbe", "sum",  "third-party-letter"
             :)
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
                    case "kbe" return
                        ()
                    case "kbp" return
                        ()
                    default return
                        <ref>
                        {$node/@*,
                         conv:body($node/node())}
                        </ref>
                        
            case element() return
                element { node-name($node) } {
                    $node/@* except $node/@id,
                    if ($node/@id) then 
                        attribute xml:id {$node/@id}
                    else 
                        (),
                    conv:body($node/node())
                }
            default return
                $node
};

conv:main()