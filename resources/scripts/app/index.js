window.addEventListener('DOMContentLoaded', () => {
    const facets = document.getElementById('facets');
    if (facets) {
        facets.addEventListener('pb-custom-form-loaded', (ev) => {
            const elems = ev.detail.querySelectorAll('.facet');
            elems.forEach((facet) => {
                facet.addEventListener('change', () => {
                    const table = facet.closest('table');
                    if (table) {
                        const nested = table.querySelectorAll('.nested .facet').forEach(function(nested) {
                            if (nested != facet) {
                                nested.checked = false;
                            }
                        });
                    }
                    facets.submit();
                });
            });
        });
    }

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

    const timelineChanged = (ev) => {
        document.querySelector('[name=dates]').value = ev.detail.categories.join(';');
        facets.submit();
    };
    pbEvents.subscribe('pb-timeline-date-changed', 'timeline', timelineChanged);
    pbEvents.subscribe('pb-timeline-daterange-changed', 'timeline', timelineChanged);
    pbEvents.subscribe('pb-timeline-reset-selection', 'timeline', () => {
        document.querySelector('[name=dates]').value = '';
        facets.submit();
    });
});