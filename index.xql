xquery version "3.1";

module namespace idx="http://teipublisher.com/index";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace dbk="http://docbook.org/ns/docbook";

declare variable $idx:app-root :=
    let $rawPath := system:get-module-load-path()
    return
        (: strip the xmldb: part :)
        if (starts-with($rawPath, "xmldb:exist://")) then
            if (starts-with($rawPath, "xmldb:exist://embedded-eXist-server")) then
                substring($rawPath, 36)
            else
                substring($rawPath, 15)
        else
            $rawPath
    ;

(:~
 : Helper function called from collection.xconf to create index fields and facets.
 : This module needs to be loaded before collection.xconf starts indexing documents
 : and therefore should reside in the root of the app.
 :)
declare function idx:get-metadata($root as element(), $field as xs:string) {
    let $header := $root/tei:teiHeader
    return
        switch ($field)
            case "title" return
                string-join((
                    $header//tei:msDesc/tei:head, $header//tei:titleStmt/tei:title[@type = 'main'],
                    $header//tei:titleStmt/tei:title,
                    $root/dbk:info/dbk:title
                ), " - ")
            case "author" return 
                idx:get-person($header//tei:correspDesc/tei:correspAction/tei:persName[@type='sender'])
            case "sender" return (
                idx:get-person($header//tei:correspDesc/tei:correspAction/tei:persName[@type='sender'])
            )
            case "addressee" return (
                idx:get-person($header//tei:correspDesc/tei:correspAction/tei:persName[@type='addressee'])
            )
            case "place" return (
                $header//tei:correspDesc/tei:correspAction/tei:placeName
            )
            case "keyword" return
                $header//tei:profileDesc//tei:keywords//tei:item
            case "notAfter" return
                idx:get-notAfter($header//tei:correspDesc//tei:date)
            case "notAfter" return
                idx:get-notBefore($header//tei:correspDesc//tei:date)
            case "language" return
                'de'
            case "date" return head((
                $header//tei:correspDesc/tei:correspAction/tei:date/@when,
                $header//tei:sourceDesc/(tei:bibl|tei:biblFull)/tei:publicationStmt/tei:date,
                $header//tei:sourceDesc/(tei:bibl|tei:biblFull)/tei:date/@when,
                $header//tei:fileDesc/tei:editionStmt/tei:edition/tei:date,
                $header//tei:publicationStmt/tei:date
            ))
            case "genre" return (
                idx:get-genre($header),
                $root/dbk:info/dbk:keywordset[@vocab="#genre"]/dbk:keyword,
                'letter'
            )
            default return
                ()
};

declare function idx:get-person($persName as element()*) {
    for $p in $persName
    return
    if ($p/@key and $p/@key != '') then $p/@key/string() else $p/string()
};

(: Escher died on Dec 6th 1882, assuming no correspondence after the end of the month would even arrive :)
declare function idx:get-notAfter($date as element()?) {
    if ($date/@when != ('', '0000-00-00')) then $date/@when else '1882-12-31'
};

(: E :)
declare function idx:get-notBefore($date as element()?) {
    if ($date/@when != ('', '0000-00-00')) then $date/@when else '1800-01-01'
};

declare function idx:get-genre($header as element()?) {
    for $target in $header//tei:textClass/tei:catRef[@scheme="#genre"]/@target
    let $category := id(substring($target, 2), doc($idx:app-root || "/data/taxonomy.xml"))
    return
        $category/ancestor-or-self::tei:category[parent::tei:category]/tei:catDesc
};
