xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare option exist:output-size-limit "-1";

let $json :=
    <timeline>
    {
        let $docs := collection("/db/apps/escher/data/briefe")//tei:text[ft:query(., (), map { "fields": ("date", "number") })]
        for $doc in $docs
        (: where ft:field($doc, "number") = ("K_0619", "K_0318") :)
        let $root := root($doc)
        let $senders := (
            $root//tei:correspAction/tei:persName[@type="sender"]/@key,
            $root//tei:correspAction/tei:orgName[@type="sender"]/string()
        )
        let $receivers := (
            $root//tei:correspAction/tei:persName[@type="addressee"]/@key,
            $root//tei:correspAction/tei:orgName[@type="addressee"]/string()
        )
        let $senderData :=
            for $sender in $senders
            return
                typeswitch($sender)
                    case element(tei:orgName) return
                        $docs/ancestor::tei:TEI//tei:orgName[. = $sender]/ancestor::tei:correspAction
                    default return
                        $docs/ancestor::tei:TEI//tei:persName[@key = $sender]/ancestor::tei:correspAction
        let $receiverData :=
            for $receiver in $receivers
            return
                typeswitch($receiver)
                    case element(tei:orgName) return
                        $docs/ancestor::tei:TEI//tei:orgName[. = $receiver]/ancestor::tei:correspAction
                    default return
                        $docs/ancestor::tei:TEI//tei:persName[@key = $receiver]/ancestor::tei:correspAction
        let $correspondence :=
            if (exists($receivers) and exists($senders)) then
                $receiverData intersect $senderData
            else if (exists($senders)) then
                $senderData
            else
                $receiverData
        return
            <corresp>
            {
                $root/tei:TEI/@xml:id,
                for $t in $correspondence
                let $date := ft:field($t, "date", "xs:date")
                group by $date
                order by $date empty least
                return
                    <date when="{substring($date, 1, 10)}">{
                        for $c in $t/ancestor::tei:TEI
                        return
                            <ref target="{$c/@xml:id}"/>
                    }</date>
            }
            </corresp>
    }
    </timeline>
let $output := serialize($json, map { "method": "xml", "indent": true() })
return
    xmldb:store("/db/apps/escher/data", "timeline.xml", $output)