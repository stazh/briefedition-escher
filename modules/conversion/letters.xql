xquery version "3.1";

declare namespace conv="http://alfred-escher.ch/app/transform/people";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $conv:MONTHS := (
    "Januar", "Februar", "März", "April", "Mai", "Juni", "Juli",
    "August", "September", "Oktober", "November", "Dezember"
);

declare function conv:main($letter as element(editedletter)) {
    let $meta := $letter/metadata
    let $otype := $letter/@otype
    let $output :=
        <TEI xml:id="{$letter/@id}" type="{$letter/@type}">
            { if ($otype) then attribute subtype {$otype} else () }
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title>{conv:title($meta)}</title>
                    </titleStmt>
                    <publicationStmt>
                        <p>Digitale Briefedition Alfred Escher, Zürich: Alfred Escher-Stiftung.</p>
                    </publicationStmt>
                    <sourceDesc>
                        {
                            for $pd in $meta/publicationdata/item[.!= '']
                            return
                                <bibl>{$pd/text()}</bibl>
                        }
                        <msDesc>
                        { conv:msIdentifier($meta/manuscriptdata) }
                        </msDesc>
                    </sourceDesc>
                </fileDesc>
                <profileDesc>
                    <textClass>
                        {
                            if ($meta/editiondata/keywords/keyword) then
                                <keywords scheme="http://briefedition.alfred-escher.ch/keywords">
                                {
                                    for $kw in $meta/editiondata/keywords/keyword
                                    return
                                        <term>{$kw/text()}</term>
                                }
                                </keywords>
                            else
                                ()
                        }
                        {
                            if ($meta/editiondata/theme != "") then
                                <keywords scheme="http://briefedition.alfred-escher.ch/theme">
                                    <term>{$meta/editiondata/theme/text()}</term>
                                </keywords>
                            else
                                ()
                        }
                    </textClass>
                    <correspDesc>
                    { conv:correspAction($meta/letterdata) }
                    </correspDesc>
                </profileDesc>
            </teiHeader>
            <text>
                <front>{conv:body($letter/letter/head/node())}</front>
                <body>{conv:body($letter/letter/body/node())}</body>
                <back>{conv:body($letter/letter/foot/node())}</back>
            </text>
        </TEI>
    return
        document { conv:fix-namespace($output) }
};

declare function conv:msIdentifier($meta as element(manuscriptdata)) {
    let $sigOrig := $meta/signature_original
    let $sigFond := $meta/fond_signature
    return
        <msIdentifier>
            <institution>{$meta/institute/text()}</institution>
            {
                if ($sigOrig != "") then
                    <idno type="original">{$sigOrig/string()}</idno>
                else
                    ()
            }
            {
                if ($sigFond != "") then
                    <idno>{$sigFond/string()}</idno>
                else
                    ()
            }
        </msIdentifier>
};

declare function conv:correspAction($meta as element(letterdata)) {
    let $origin := $meta/place[@type="origin"]
    let $destination := $meta/place[@type="destination"]
    return (
        <correspAction type="sent">
        {
            $meta/(from|to) ! conv:fromTo(.),
            if ($origin != "") then
                <placeName>{$origin/text()}</placeName>
            else
                (),
            for $date in $meta/date[not(@type)]
            let $when := replace($date/@norm, "^0000-", "1000-") => replace('-00', '-01')
            return
                <date when="{$when}">{conv:date($date)}</date>
        }
        </correspAction>,
        if ($destination != "") then
            <correspAction type="received">
                <placeName>{$destination/text()}</placeName>
            </correspAction>
        else
            ()
    )
};

declare function conv:fromTo($fromTo as element()) {
    let $type := if ($fromTo instance of element(to)) then "sender" else "addressee"
    return
        if ($fromTo/name) then
            for $name in $fromTo/name
            return
                <persName key="{$name/@norm}" type="{$type}">{string-join(($name/firstname, $name/lastname), ' ')}</persName>
        else
            <orgName type="{$type}">{$fromTo/text()}</orgName>
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

declare function conv:title($meta as element(metadata)) {
    let $from := string-join(conv:display-name($meta/letterdata/from), " und ")
    let $to := string-join(conv:display-name($meta/letterdata/to), " und ")
    let $date := string-join(conv:dates($meta/letterdata/date))
    let $weekdays := string-join($meta/letterdata/weekday[. != ""], " / ")
    let $place := $meta/letterdata/place[@type="origin"]
    let $placeStr := if ($place and $place != "") then $place/text() else "s.l."
    return
        ``[`{$from}` an `{$to}`, `{$placeStr}`, `{if ($weekdays) then $weekdays || ', ' else ()}``{$date}`]``
};

declare function conv:dates($dates as element(date)*) {
    if (empty($dates)) then
        ()
    else
        let $date := head($dates)
        let $next := $dates[2]
        return (
            if ($next and $date/month = $next/month and $date/year = $next/year) then
                (conv:date-component($date/day), " / ")
            else
                (conv:date($date), if (count($dates) > 1) then ", " else ""),
            conv:dates(tail($dates))
        )
};

declare function conv:date($date as element(date)) {
    if ($date/@type) then
        "s.d."
    else
        let $components :=
            for $comp in ($date/day, $date/month, $date/year)
            return
                conv:date-component($comp)
        return
            normalize-space(string-join(conv:date-to-string($components, false())))
};

declare function conv:date-to-string($components, $openBracket as xs:boolean?) {
    if (exists($components)) then
        let $next := head($components)
        return
            if (normalize-space($next) = "") then
                conv:date-to-string(tail($components), $openBracket)
            else if ($next instance of element(add)) then
                if ($openBracket) then
                    (' ', $next, conv:date-to-string(tail($components), true()))
                else
                    (' [', $next, conv:date-to-string(tail($components), true()))
            else
                if ($openBracket) then
                    ('] ', $next, conv:date-to-string(tail($components), false()))
                else
                    (' ', $next, conv:date-to-string(tail($components), false()))
    else if ($openBracket) then
        ']'
    else
        ()
};

declare function conv:date-component($nodes as node()*) {
    for $node in $nodes
    return
        typeswitch($node)
            case element(add) return
                if ($node/@type="?") then
                    <add>{conv:date-component($node/node())}?</add>
                else
                    <add>{conv:date-component($node/node())}</add>
            case element() return
                conv:date-component($node/node())
            case text() return
                if ($node/ancestor::day and matches($node, "\d+")) then
                    ($node || ".")
                else if ($node/ancestor::month and matches($node, "\d+")) then
                    $conv:MONTHS[xs:int($node)]
                else
                    $node
            default return
                $node
};

declare function conv:display-name($fromTo as element()) {
    if ($fromTo/name) then
        for $name in $fromTo/name
        return
            string-join(($name/firstname, $name/lastname), ' ')
    else
        $fromTo/string()
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
                <choice><abbr>{conv:body($node/node())}</abbr><expan>{$node/@norm/string()}</expan></choice>
            case element(d) return
                let $tokens := tokenize($node/@norm, '\.')
                let $norm := string-join(reverse($tokens), '-') => translate('?', '')
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
            case element(c) | element(sh) | element(printedheader) | element(delei) return
                conv:body($node/node())
            case element(ins) return
                <add>{conv:body($node/node())}</add>
            case element(obj) return
                <orig>{conv:body($node/node())}</orig>
            case element(r) return
                <rs>{conv:body($node/node())}</rs>
            case element(hi) return
                <hi>{conv:body($node/node())}</hi>
            case element(u) return
                <hi rend="underline">{conv:body($node/node())}</hi>
            case element(sup) return
                <hi rend="sup">{conv:body($node/node())}</hi>
            case element(dateline) return
                <div type="dateline">{conv:body($node/node())}</div>
            case element(address) return
                <div type="opener">{conv:body($node/node())}</div>
            case element(salutation) return
                <div>{$node/@type, conv:body($node/node())}</div>
            case element(signature) return
                <div type="signature">{conv:body($node/node())}</div>
            case element(postscriptum) return
                <postscript>{conv:body($node/node())}</postscript>
            case element(transcript) return
                <note type="transcript">{conv:body($node/node())}</note>
            case element(printed) return
                <hi rend="printed">{conv:body($node/node())}</hi>
            case element(annotation) return
                <div type="annotation">{conv:body($node/node())}</div>
            case element(attachment) return
                <div type="attachment">{conv:body($node/node())}</div>
            case element(table) return
                <table>{conv:body($node/node())}</table>
            case element(tr) return
                <row>{conv:body($node/node())}</row>
            case element(tab) return
                <cell>{conv:body($node/node())}</cell>
            case element(lb) | element(br) return
                <lb xml:id="{$node/@id}">{if ($node/preceding-sibling::node()[1][self::sh]) then attribute break { "no" } else ()}</lb>
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

for $letter in collection("/db/escher")/editedletter
return
    file:serialize(conv:main($letter), xs:anyURI("/workspaces/data/" || util:document-name($letter)), ("omit-xml-declaration=no", "indent=no"))