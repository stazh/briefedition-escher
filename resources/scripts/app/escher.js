function findEndOfRange(current, selector) {
    let last = null;
    let next = current.nextSibling;
    while(next) {
        if (next.nodeType === Node.ELEMENT_NODE && next.matches(selector)) {
            return last;
        }
        last = next;
        next = next.nextSibling;
    }
    return last;
}

window.addEventListener('load', () => {
    pbEvents.subscribe('pb-update', 'transcription', (ev) => {
        const root = ev.detail.root;
        root.querySelectorAll('br').forEach((br) => {
            const next = findEndOfRange(br, 'br');
            if (!next) {
                return;
            }
            const wrapper = document.createElement('span');
            wrapper.className = 'line';
            const range = document.createRange();
            range.setStartBefore(br);
            range.setEndAfter(next);
            range.surroundContents(wrapper);
        });
    });
});