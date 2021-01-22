xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";

(:declare default element namespace "http://www.tei-c.org/ns/1.0";:)



declare function local:convert($nodes as node()*) {
    for $node in $nodes
    return
        typeswitch($node)
            case element(editedletter) return
                <TEI xmlns="http://www.tei-c.org/ns/1.0">
                    {
                        attribute xml:id {$node/@id},
                        attribute n {$node/@nr},
                        attribute type {$node/@type},
                        local:convert($node/node())
                    }
                </TEI>
            case element(metadata) return
                local:metadata($node/node())
            case element(letter) return
                <text xmlns="http://www.tei-c.org/ns/1.0">
                    {local:convert($node/node())}
                </text>
            case element(head) return
                <front xmlns="http://www.tei-c.org/ns/1.0">
                    {local:convert($node/node())}
                </front>
            case element(body) return
                <body xmlns="http://www.tei-c.org/ns/1.0">
                    <div xmlns="http://www.tei-c.org/ns/1.0">
                    {local:convert($node/node())}
                    </div>
                </body>
            case element(address) return
                <div type="address" xmlns="http://www.tei-c.org/ns/1.0">
                    {local:convert($node/node())}
                </div>
            case element(signature) return
                <div type="address" xmlns="http://www.tei-c.org/ns/1.0">
                    {local:convert($node/node())}
                </div>
            case element(dateline) return
                <div type="dateline" xmlns="http://www.tei-c.org/ns/1.0">
                    {$node/@*,
                    local:convert($node/node())}
                </div>
            case element(attachment) return
                <div type="attachment" xmlns="http://www.tei-c.org/ns/1.0">
                    {$node/@*,
                    local:convert($node/node())}
                </div>
            case element(salutation) return
                <div xmlns="http://www.tei-c.org/ns/1.0">
                    {
                        attribute type {$node/@type},
                        local:convert($node/node())
                    }
                </div>
            case element(foot) return
                <back xmlns="http://www.tei-c.org/ns/1.0">
                    {local:convert($node/node())}
                </back>
            case element(printedheader) return
                <div xmlns="http://www.tei-c.org/ns/1.0" type="printedheader">
                    {
                        local:convert($node/node())
                    }
                </div>
            case element(printed) return
                <fw xmlns="http://www.tei-c.org/ns/1.0">
                    {
                        local:convert($node/node())
                    }
                </fw>
            case element(p) return
                <p xmlns="http://www.tei-c.org/ns/1.0">
                    {
                        $node/@* except ($node/@id),
                        if ($node/@id) then attribute xml:id {$node/@id} else (),
                        local:convert($node/node())
                    }
                </p>
            case element(lb) | element(br) return
                <lb xmlns="http://www.tei-c.org/ns/1.0">
                    {
                        $node/@* except ($node/@id),
                        if (local-name(($node/preceding-sibling::*)[last()])='sh') then attribute break {'no'} else (),
                        if ($node/@id) then attribute xml:id {$node/@id} else (),
                        local:convert($node/node())
                    }
                </lb>
            (:  hyphens are treated via lb element :)
            case element(sh) return
                ()
            case element(pb) return
                <pb xmlns="http://www.tei-c.org/ns/1.0">
                    {
                        $node/@*,
                        local:convert($node/node())
                    }
                </pb>
            case element(d) return
                <date xmlns="http://www.tei-c.org/ns/1.0">
                        {
                            $node/@* except ($node/@norm, $node/@id),
                            if ($node/@id) then attribute xml:id {$node/@id} else (),
                            if ($node/@norm) then attribute when {local:convertDate($node/@norm)} else (),
                            local:convert($node/node())
                        }
                </date>
            case element(idx) return
                if ($node/@type = 'place') then
                    <placeName xmlns="http://www.tei-c.org/ns/1.0">
                        {
                            $node/@* except ($node/@norm),
                            attribute key {$node/@norm},
                            local:convert($node/node())
                        }
                    </placeName>
                else
                    <persName xmlns="http://www.tei-c.org/ns/1.0">
                        {
                            $node/@* except ($node/@norm),
                            attribute key {$node/@norm},
                            local:convert($node/node())
                        }
                    </persName>
            case element(abbr) return
                <choice xmlns="http://www.tei-c.org/ns/1.0">
                    <abbr>{local:convert($node/node())}</abbr>
                    <expan>{$node/@norm/string()}</expan>
                </choice>
            case element(add) return
                if ($node/ancestor::metadata) then
                    ('[', local:convert($node/node()), if ($node/@type="?") then '?' else (), ']')
                else
                <supplied xmlns="http://www.tei-c.org/ns/1.0">
                    {
                        $node/@* except ($node/@id, $node/@type),
                        if ($node/@id) then attribute xml:id {$node/@id} else (),
                        if ($node/@type) then attribute type {local:mapType($node/@type)} else (),
                        local:convert($node/node())}
                </supplied>
            case element(ins) return
                <add xmlns="http://www.tei-c.org/ns/1.0">
                    {
                        $node/@* except ($node/@id),
                        if ($node/@id) then attribute xml:id {$node/@id} else (),
                        local:convert($node/node())}
                </add>
            case element(del) return
                <del xmlns="http://www.tei-c.org/ns/1.0">
                    {
                        $node/@* except ($node/@id),
                        if ($node/@id) then attribute xml:id {$node/@id} else (),
                        local:convert($node/node())}
                </del>
            case element(c) return
                <seg type="com" xmlns="http://www.tei-c.org/ns/1.0">
                        {
                            $node/@*,
                            local:convert($node/node())
                        }
                </seg>
            case element(com) return
                <note xmlns="http://www.tei-c.org/ns/1.0">
                        {
                            $node/@* except ($node/@id),
                            if ($node/@id) then attribute xml:id {$node/@id} else (),
                            local:convert($node/node())
                        }
                </note>
            case element(transcript) return
                <note type="transcript" xmlns="http://www.tei-c.org/ns/1.0">
                        {
                            $node/@* except ($node/@id),
                            if ($node/@id) then attribute xml:id {$node/@id} else (),
                            local:convert($node/node())
                        }
                </note>
            case element(annotation) return
                <note type="annotation" xmlns="http://www.tei-c.org/ns/1.0">
                        {
                            $node/@* except ($node/@id),
                            if ($node/@id) then attribute xml:id {$node/@id} else (),
                            local:convert($node/node())
                        }
                </note>
            case element(r) return
                <seg type="ref" xmlns="http://www.tei-c.org/ns/1.0">
                        {
                            $node/@*,
                            local:convert($node/node())
                        }
                </seg>
            case element(u) return
                <hi xmlns="http://www.tei-c.org/ns/1.0" rend="underline">
                        {
                            $node/@* except ($node/@id),
                            if ($node/@id) then attribute xml:id {$node/@id} else (),
                            local:convert($node/node())
                        }
                </hi>
            case element(sup) return
                <hi xmlns="http://www.tei-c.org/ns/1.0" rend="sup">
                        {
                            $node/@* except ($node/@id),
                            if ($node/@id) then attribute xml:id {$node/@id} else (),
                            local:convert($node/node())
                        }
                </hi>
            case element(hi) return
                <hi xmlns="http://www.tei-c.org/ns/1.0">
                        {
                            $node/@* except ($node/@id),
                            if ($node/@id) then attribute xml:id {$node/@id} else (),
                            local:convert($node/node())
                        }
                </hi>
            case element(ref) return
                <ref xmlns="http://www.tei-c.org/ns/1.0">
                        {
                            $node/@* except ($node/@id),
                            if ($node/@id) then attribute xml:id {$node/@id} else (),
                            local:convert($node/node())
                        }
                </ref>
            case element(obj) return
                <bibl xmlns="http://www.tei-c.org/ns/1.0">
                        {
                            $node/@* except ($node/@id),
                            if ($node/@id) then attribute xml:id {$node/@id} else (),
                            local:convert($node/node())
                        }
                </bibl>
            case element(table) return
                <table xmlns="http://www.tei-c.org/ns/1.0">
                        {
                            $node/@* except ($node/@id),
                            if ($node/@id) then attribute xml:id {$node/@id} else (),
                            local:convert($node/node())
                        }
                </table>   
            case element(tr) return
                <row xmlns="http://www.tei-c.org/ns/1.0">
                        {
                            $node/@* except ($node/@id),
                            if ($node/@id) then attribute xml:id {$node/@id} else (),
                            local:convert($node/node())
                        }
                </row>   
            case element(tab) return
                <cell xmlns="http://www.tei-c.org/ns/1.0">
                        {
                            $node/@* except ($node/@id),
                            if ($node/@id) then attribute xml:id {$node/@id} else (),
                            local:convert($node/node())
                        }
                </cell>   
            case element(postscriptum) return
                <postscript xmlns="http://www.tei-c.org/ns/1.0">
                        {
                            $node/@* except ($node/@id),
                            if ($node/@id) then attribute xml:id {$node/@id} else (),
                            local:convert($node/node())
                        }
                </postscript>
            case element(metamark) return
                <metamark xmlns="http://www.tei-c.org/ns/1.0">
                        {
                            $node/@* except ($node/@id),
                            if ($node/@id) then attribute xml:id {$node/@id} else (),
                            local:convert($node/node())
                        }
                </metamark> 
(:  handling metadata parts              :)
            case element(keyword) return
                <item xmlns="http://www.tei-c.org/ns/1.0">
                    {
                        $node/@* except ($node/@id),
                        if ($node/@id) then attribute xml:id {$node/@id} else (),
                        local:convert($node/node())
                    }
                </item>
            case element(place) return
               local:convert($node/node())
            case element(year) return
               local:convert($node/node())
            case element(month) return
               local:convert($node/node())
            case element(day) return
               local:convert($node/node())
            case element(date) return 
                local:convert($node/node())
(:     everything else           :)
            case element() return
                    element { node-name($node) } {
                        $node/@*, local:convert($node/node())
                    }
            default return
                $node
};

declare function local:mapType($param) {
    if ($param = '?') then 'unclear' else $param
};

declare function local:convertDate($date) {
    let $a := analyze-string($date, '\.')/fn:non-match
    return
    string-join(reverse($a), '-')
};

declare function local:titleDate($date) {
    try {
        format-date($date/@norm, '[F], [MNn] [D1], [Y0001]', 'de', (), ())
    } catch * {
        normalize-space(string-join(local:convert($date)))
    }
};

declare function local:titleDateWhen($date) {
    try {
        format-date($date, '[Y0001]-[M01]-[D01]', 'de', (), ())
    } catch * {
        string-join(reverse(for $f in $date/child::*[normalize-space(.)!=''] return normalize-space($f)), '-')
    }
};

declare function local:revisionDesc($metadata) {
    for $i in $metadata//*:item
    return
        for $d in $i/*:revisiondate
        return
        <change xmlns="http://www.tei-c.org/ns/1.0">
            {
                attribute when {local:convertDate($d)},
                attribute who {$i/*:resp/string()},
                $i/text()
            }
        </change>
};

declare function local:title($metadata) {
    let $from := local:person($metadata//*:from)
    let $senders := 
        if (count($from?persons)) then
            string-join(for $p in $from?persons return $p?label, ' und ')
        else
            $from?label

    let $to := local:person($metadata//*:to)
    let $addressees := 
        if (count($to?persons)) then
            string-join(for $p in $to?persons return $p?label, ' und ')
        else
            $to?label
    
    let $correspondents := string-join(($senders, $addressees), ' an ')
    let $place := local:place($metadata//*:place[@type="origin"])
    let $date := local:titleDate($metadata/*:date)
    
    return string-join(($correspondents, $place, $date), ', ')
};

declare function local:person($person) {
    if ($person/*:name) then 
        map {"persons": 
            for $n in $person/*:name
            return
                map {
                    "label": string-join($n/child::*/string(), ' '),
                    "key": $n/@norm
                }
        }
    else
        map {
                "label": $person/string()
            }
};
declare function local:place($place) {
    if ($place/string() != '') then local:convert($place) else 's.l.'
};

declare function local:msDesc($metadata) {
    let $ms := $metadata/descendant-or-self::*:manuscriptdata
    return
        if ($ms/descendant-or-self::*:signature_original/string() != '') then 
            $ms/descendant-or-self::*:signature_original/string()
        else
            normalize-space(string-join(($ms/descendant-or-self::*:fond_title, $ms/descendant-or-self::*:fond_signature, $ms/descendant-or-self::*:doc_signature), ' '))
};

declare function local:metadata($metadata) {
  <teiHeader xmlns="http://www.tei-c.org/ns/1.0">
        <fileDesc>
            <titleStmt>
                <title>{local:title($metadata)}</title>
            </titleStmt>
            <publicationStmt>
                <p>Digitale Briefedition Alfred Escher, Zürich: Alfred Escher-Stiftung.</p>
            </publicationStmt>
            <sourceDesc>
            <msDesc>
               <msIdentifier>
                   {if ($metadata/ancestor::*:editedletter/@otype != '') then attribute type {$metadata/ancestor::*:editedletter/@otype} else ()}
                  <institution>{$metadata/descendant-or-self::*:manuscriptdata//*:institute/string()}</institution>
                  <idno type="original">{local:msDesc($metadata)}</idno>
               </msIdentifier>
            </msDesc>
         </sourceDesc>
        </fileDesc>
        <profileDesc>
            <textClass>
                <keywords scheme="escher">
                   <list>
                   {local:convert($metadata//*:keyword)}
                   </list>
                </keywords>
            </textClass>
            <correspDesc>
                <correspAction type="sent">
                {   
                    let $from := local:person($metadata//*:from)
                    return 
                        if (count($from?persons)) then
                            for $p in $from?persons
                            return
                            <persName key="{$p?key}" type="sender">{$p?label}</persName>
                        else
                            <persName type="sender">{$from?label}</persName>
                }
                {   
                    let $to := local:person($metadata//*:to)
                    return 
                        if (count($to?persons)) then
                            for $p in $to?persons
                            return
                            <persName key="{$p?key}" type="addressee">{$p?label}</persName>
                        else
                            <persName type="sender">{$to?label}</persName>
                }
                    <placeName>{local:place($metadata//*:place[@type='origin'])}</placeName>
                   <date when="{local:titleDateWhen($metadata/*:date)}">{local:titleDate($metadata/*:date)}</date>
                </correspAction>
            </correspDesc>
        </profileDesc>
        <revisionDesc>
          {local:revisionDesc($metadata)}
        </revisionDesc>
  </teiHeader>
};


(: let $escher := doc('/db/apps/escher/data/temp/K_8419_EidgenssischerVorort_an_Escher_1848-10-26.xml')/*:editedletter :)
(: return local:convert($escher) :)

for $letter in collection('/db/apps/escher/data/temp')/*:editedletter

let $file := util:document-name($letter)
let $contents := local:convert($letter)

return xmldb:store('/db/apps/escher/data/letters', $file, $contents)