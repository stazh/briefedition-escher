xquery version "3.1";

(:~
 : Shared extension functions for Escher.
 :)
module namespace pmf="http://www.tei-c.org/tei-simple/xquery/functions/escher-common";

(:~
 : Output different date formats as human readable and German date strings
 : Reads the value of attribute "when", e.g.: 'when="04-05"'
 :)
declare function pmf:format-date($date as xs:string*) {
    let $when := $date/@when/string()
    return
        (: '2009-10' :)
        if ($when castable as xs:gYearMonth) then
            format-date(xs:date($when ||"-01"), "[MNn] [Y0001]", "de", (), ())
        (: '2001-12-03' :)
        else if ($when castable as xs:date) then
            format-date(xs:date($when), " [D]. [MNn] [Y0001]", "de", (), ())
        (: '09-10' :)
        else if (matches($when, "^\d{2}-\d{2}$")) then
            format-date('1000-' || $date, "[D1]. [MNn]", "de", (), ())
        else ()
};
