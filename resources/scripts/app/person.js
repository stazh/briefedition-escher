
const sources = {
    "dodis": "Dodis",
    "sikart": "SIKART Lexikon zur Kunst in der Schweiz",
    "hls-dhs-dss": "HLS-DHS",
    "burgerbibliothek": "Burgerbibliothek Bern",
    "histhub": "histHub",
    "helveticat": "Helveticat",
    "parlamentch": "Schweizer Parlament",
    "elites-suisses-au-xxe-siecle": "Base de données “élites suisses au XXe siècle”",
    "ethz": "ETH-Bibliothek",
    "hallerNet": "hallernet",
    "gnd": "Gemeinsame Normdatei",
    "viaf": "VIAF",
    "hfls": "Historisches Familienlexikon der Schweiz",
    "bsg": "Bibliographie der Schweizergeschichte"
};

window.addEventListener('DOMContentLoaded', () => {
    pbEvents.subscribe('before-person-update', 'transcription', (ev) => {
        const root = ev.detail.root;

        const target = document.getElementById('gallery');
        const galleries = root.querySelectorAll('.splide');
        galleries.forEach((gallery) => {
            gallery.remove();
            target.appendChild(gallery);
            const splide = new Splide(gallery, {
                pagination: false,
                autoplay: true,
                type: 'loop'
            });
            splide.mount();
        });

        ev.detail.render(root);

        const links = document.getElementById('metagrid');
        const gnd = root.querySelector('[data-gnd]').getAttribute('data-gnd');
        fetch(`https://api.metagrid.ch/search?query=${gnd}&provider=gnd`)
        .then((response) => {
            if (response.ok) {
                return response.json();
            }
        })
        .then((json) => {
            if (json.meta && json.meta.total > 0) {
                const concordance = json.resources[0].concordance.uri;
                fetch(concordance)
                .then((response) => {
                    if (response.ok) {
                        return response.json();
                    }
                })
                .then((json) => {
                    json.concordances.forEach((concordance) => {
                        concordance.resources.forEach((resource) => {
                            const slug = resource.provider.slug;
                            if (slug == 'alfred-escher') {
                                return;
                            }
                            const link = document.createElement('a');
                            link.href = resource.link.uri;
                            link.innerHTML = sources[slug] || slug;
                            link.target = '_blank';
                            links.appendChild(link);
                        });
                    });
                });
            }
        });
    });
});