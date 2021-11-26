xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";

let $docs := collection("/db/apps/escher/data/briefe")//tei:text[ft:query(., (), map { "fields": "date" })]
let $sorted :=
    for $t in $docs
    order by ft:field($t, "date", "xs:date") empty least
    return
        $t
for $doc in $docs
let $root := root($doc)
let $sender := $root//tei:correspAction/tei:persName[@type="sender"]/@key
let $receiver := $root//tei:correspAction/tei:persName[@type="addressee"]/@key
let $correspondence :=
    if ($receiver and $sender) then
        $docs/ancestor::tei:TEI//tei:persName[@key = $sender]/ancestor::tei:correspAction intersect
        $docs/ancestor::tei:TEI//tei:persName[@key = $receiver]/ancestor::tei:correspAction
    else if ($sender) then
        $docs/ancestor::tei:TEI//tei:persName[@key = $sender]/ancestor::tei:correspAction
    else
        $docs/ancestor::tei:TEI//tei:persName[@key = $receiver]/ancestor::tei:correspAction
let $correspSorted :=
    for $t in $correspondence
    order by ft:field($t, "date", "xs:date") empty least
    return
        root($t)
let $index :=
    for $item at $p in $sorted
    where $item is $doc
    return
        $p
let $indexCorresp :=
    for $item at $p in $correspSorted
    where $item is $root
    return
        $p
let $context :=
    <correspContext xmlns="http://www.tei-c.org/ns/1.0">
    {
        if ($index > 1) then
            <ref type="previous" target="B{substring-after(root($sorted[$index - 1])/tei:TEI/@xml:id, 'K_')}"/>
        else
            ()
    }
    {
        if ($index < count($sorted)) then
            <ref type="next" target="B{substring-after(root($sorted[$index + 1])/tei:TEI/@xml:id, 'K_')}"/>
        else
            ()
    }
    {
        if ($indexCorresp < count($correspSorted)) then
            <ref type="next-in-corresp" target="B{substring-after(root($correspSorted[$indexCorresp + 1])/tei:TEI/@xml:id, 'K_')}"/>
        else
            ()
    }
    {
        if ($indexCorresp > 1) then
            <ref type="previous-in-corresp" target="B{substring-after(root($correspSorted[$indexCorresp - 1])/tei:TEI/@xml:id, 'K_')}"/>
        else
            ()
    }
    </correspContext>
return (
    update insert $context into $root//tei:correspDesc,
    let $doc := doc(document-uri(root($doc)))
    return
        file:serialize($doc, xs:anyURI("/workspaces/data/" || util:document-name($doc)), ("omit-xml-declaration=no", "indent=no"))
)