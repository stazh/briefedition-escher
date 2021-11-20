window.addEventListener('DOMContentLoaded', () => {
    // click on term: submit facet search
    pbEvents.subscribe('pb-end-update', 'docs', () => {
        document.querySelectorAll('pb-browse-docs .term').forEach((term) => {
            term.addEventListener('click', (ev) => {
                ev.preventDefault();
                const params = {};
                params['facet-keyword'] = term.innerText;
                pbEvents.emit('pb-search-resubmit', 'docs', { params });
            });
        });
    });
});