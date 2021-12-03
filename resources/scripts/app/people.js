
window.addEventListener('WebComponentsReady', () => {
    const form = document.getElementById('options');
    const search = document.getElementById('query');
    const url = new URL(location.href);
    let prevQuery = '';

    function getFormParams() {
        const params = form.serializeForm();
        if (params.search == null) {
            delete params.search;
        } else {
            prevQuery = params.search;
        }
        url.searchParams = '';
        for (let key in params) {
            if (params.hasOwnProperty(key)) {
                url.searchParams.set(key, params[key]);
            }
        }
        return params;
    }

    function submit(ev) {
        ev.preventDefault();
        pbEvents.emit('pb-load', 'transcription', { params: getFormParams() });
    }

    const params = new URLSearchParams(location.search);
    search.value = params.get('search');
    search.addEventListener('keyup', (e) => {
        if (search.value.length > 1 || prevQuery.length > 0) {
            submit(e);
        }
    });
    search.querySelector('paper-icon-button').addEventListener('click', submit);

    document.querySelectorAll('input[name=view]').forEach((input) => {
        input.addEventListener('change', submit);
    });

    pbEvents.subscribe('pb-end-update', 'transcription', () => {
        document.querySelectorAll('.people-list header a').forEach(link => {
            link.addEventListener('click', (ev) => {
                ev.preventDefault();
                document.querySelector('[name=letter]').value = link.hash.substring(1);
                const params = getFormParams();
                pbEvents.emit('pb-load', 'transcription', { params });
            });
        });
        const header = document.querySelector('.people-list header');
        if (header) {
            const letter = header.getAttribute('data-active');
            document.querySelector('[name=letter]').value = letter;
            url.searchParams.set('letter', letter);
            history.pushState('people', 'display people', url.toString());
        }
    });

    const initial = getFormParams();
    pbEvents.emit('pb-load', 'transcription', { params: initial });
});