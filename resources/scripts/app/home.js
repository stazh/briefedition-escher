const data = [
    {
        letter: "B6036",
        text: "«Grafenried war bei der Königin zum Thee, und da wird gegotthardet worden sein. Aber mit sympatischen Redensarten bohrt man keinen Alpentunnel.»",
        source: "Maximilian Heinrich von Roeder an Alfred Escher, 15. März 1870"
    },
    {
        letter: "B0195",
        text: "«Was wir schießen ist unsere Nahrung, an Vögeln fehlt es nicht u oft giebt es Eichhörnchen od. Affen in den Topf.»",
        source: "Johann Jakob Tschudi an Alfred Escher, 4. Juli 1839"
    },
    {
        letter: "B0638",
        text: "«Wir Liberale sind vollkommen geschlagen worden &amp; die Reaction feiert nun ihren Sieg in Uri.»",
        source: "Josef Lusser an Alfred Escher, 7. Mai 1849"
    },
    {
        letter: "B6058",
        text: "«Gelingt es, Herrn von Bismark aus politischen Gründen zu gewinnen, dann ist es wahrscheinlich gar nicht mehr nöthig, noch weitere Schritte in Berlin zu thun.»",
        source: "Franz von Roggenbach an Alfred Escher, 17. August 1865"
    },
    {
        letter: "B4432",
        text: "«Verehrtester Herr Präsident! Sie stehen gegenwärtig auf der höchsten Stuffe wohlverdienten Ruhmes. Sie haben durch Ihre eminente Kraft &amp; unermüdliche Ausdauer ein Werk zu Stande gebracht, wie noch kein schweizerischer Staatsmann Eines geschaffen.»",
        source: "Josef Zingg an Alfred Escher, 13. Oktober 1871"
    },
    {
        letter: "B3269",
        text: "«Ich habe nun also die Wahl in den Verwaltungsrath der Creditanstalt anzunehmen erklärt. Die Aussicht, dadurch mit Ihnen wieder in öftere Berührung zu kommen, hat nicht  am wenigsten, sondern am meisten zu meinem Entschlusse beigetragen.»",
        source: "Alfred Escher an Georg Stoll, 4. April 1880"
    },
    {
        letter: "B1903",
        text: "«Die Kinder prosperiren auch sichtlich &amp; streben der vollkommensten geometrischen Figur, der Kugel, zu!»",
        source: "Alfred Escher an Johann Jakob Blumer, 4. November 1861"
    },
    {
        letter: "B1399",
        text: "«Für einstweilen scheint man im Bundesrath einstimmig der Meinung zu seyn, daß ohne ganz überwiegende Gründe, die noch gar nicht in der jetzigen Constellation liegen, die Neutralität um jeden Preis festgehalten werden soll.»",
        source: "Jonas Furrer an Alfred Escher, 18. Februar 1855"
    },
    {
        letter: "B0112",
        text: "«Doch immer, wenn ich noch so herrliche Naturschönheiten u. noch so prächtige Puncte gesehen habe, finde ich Zürichs freundliche Lage an dem lieblichen See immer die schönste und immer habe ich mit einem gewissen Stolze seine Lage mit andern verglichen!»",
        source: "Alfred Escher an Alexander Schweizer, 27. August 1832"
    },
    {
        letter: "B0322",
        text: "«Der größte Feind der liberalen Schweiz liegt in ihrer Schweizerischen &amp; kantonalen Desorganisation!»",
        source: "Alfred Escher an Arnold Otto Aepli, 16. Juni 1844"
    },
    {
        letter: "B0588",
        text: "«Ich bedaure, daß die Frage des Bundessitzes gleich im Anfange der Verhandlungen der Bundesversammlung den Teufel des Cantonalegoismus heraufbeschwören wird &amp; daß wir Zürcher gezwungen sein werden, nicht das wenigste dazu beizutragen.»",
        source: "Alfred Escher an Franz Hagenbuch, 26. Oktober 1848"
    },
    {
        letter: "B0728",
        text: "«Hebe meine Briefe auf, wie ich die Deinen, wir wollen sie später drucken lassen: ‹Briefwechsel eines Eidgen. Staatsmannes mit einem Particülar-Zürcherischen Idioten›.»",
        source: "Friedrich Gustav Ehrhardt an Alfred Escher, 11. Dezember 1849"
    },
    {
        letter: "B8379",
        text: "«Sehr würde es mich freuen, bald einmal zu hören, daß ein Stück von Ihnen über eine bedeutende Bühne in Deutschland gegangen &amp; daß der Dichter des Stückes, mein ehemaliger Waffengefährte – in der Zürcherschen Staatscanzlei, einen Lorbeerkranz davon getragen habe!»",
        source: "Alfred Escher an Gottfried Keller, 22. März 1851"
    }
];

images = [
    "K_0026_1r_v1.jpg",
    "K_0026_1r_v1_Dm3RR2q.jpg",
    "K_0026_1r_v1_bihFssI.jpg",
    "K_0026_1r_v1_v97gq8t.jpg",
    "K_0086_1r_hmff97z.jpg",
    "K_0086_1r_v1.jpg",
    "K_0097_1r_v1.jpg",
    "K_0195_1r.jpg",
    "K_0261_1r_v1_OHfnEvo.jpg",
    "K_0261_1r_v1_g05aHMH.jpg",
    "K_0261_1r_v1_g7dI54a.jpg",
    "K_0261_1r_v1_scPLCzK.jpg",
    "K_0265_1r_v1.jpg",
    "K_0265_1r_v1_ATP91Lh.jpg",
    "K_0265_1r_v1_zR3AE0v.jpg",
    "K_0467_1r_v1.jpg",
    "K_1044_1r_v1.jpg",
    "K_1057_1_v1.jpg",
    "K_1230_2r_ZAavaTO.jpg",
    "K_1230_2r_v1.jpg",
    "K_1434_1r_v1.jpg",
    "K_1434_1r_v1_UvHr4PE.jpg",
    "K_1461_2r_v1.jpg",
    "K_2012_1r_v1.jpg",
    "K_2012_1r_v1_s4uKRI5.jpg",
    "K_2039_1r_v1.jpg",
    "K_2039_1r_v1_qA5NGpN.jpg",
    "K_2039_1r_v2.jpg",
    "K_2088_1r_v1.jpg",
    "K_2115_2r_v1.jpg",
    "K_2132_1r_v1.jpg",
    "K_2240_2v_v1.jpg",
    "K_2855_1r_v1.jpg",
    "K_2855_1r_v2.jpg",
    "K_3328_1r_v1.jpg",
    "K_4632_7_v1.jpg",
    "K_4781_1r_v1.jpg",
    "K_5872_1v_v1.jpg",
    "K_7355_1r_v1.jpg",
    "K_7355_1r_v1_55xkByP.jpg",
    "K_7906_03r_v1.jpg"
];

window.addEventListener('DOMContentLoaded', () => {

    const facsimile = document.querySelector('.facsimile');
    const container = document.querySelector('.quote');
    const appRoot = container.dataset.app;

    function randomImage() {
        const next = Math.floor(Math.random() * images.length);
        facsimile.style.backgroundImage = `url(resources/images/home/${images[next]})`;
        const id = images[next].replace(/^K_(\d+)_.*$/, 'B$1');
        facsimile.href = `${appRoot}/briefe/${id}?view1=1`;
    }

    function randomQuote() {
        const bottom = document.querySelector('.bottom');

        const text = container.querySelector('p');
        const source = container.querySelector('.source');
        const next = Math.floor(Math.random() * data.length);
        text.innerHTML = data[next].text;
        source.innerHTML = data[next].source;
        container.href = `${appRoot}/briefe/${data[next].letter}`;
    }

    randomImage();
    randomQuote();
    setInterval(randomQuote, 5000);
    setInterval(randomImage, 4000);
});