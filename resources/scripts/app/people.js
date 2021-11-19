
window.addEventListener('DOMContentLoaded', () => {
    const form = document.getElementById('options');

    function submit(ev) {
        ev.preventDefault();
        const params = form.serializeForm();
        pbEvents.emit('pb-search-resubmit', 'grid', { params });
    }

    const search = document.getElementById('query');
    const params = new URLSearchParams(location.search);
    search.value = params.get('search');
    search.addEventListener('keyup', (e) => e.keyCode == 13 ? submit(e) : null);
    search.querySelector('paper-icon-button').addEventListener('click', submit);

    document.querySelectorAll('input[name=view]').forEach((input) => {
        input.addEventListener('change', submit);
    });
});