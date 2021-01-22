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

let root;

// find popovers containing the id in their data-ref attribute and call the callback for each.
function findPopovers(id, callback) {
    root.querySelectorAll(`pb-popover[data-ref=${id}]`).forEach(callback);
}

window.addEventListener('load', () => {
    pbEvents.subscribe('pb-update', 'transcription', (ev) => {
        root = ev.detail.root;
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

    // wait until register content has been loaded, then walk trough the transcription
    // and extend all persName, placeName etc. popovers with the additional information
    pbEvents.subscribe('pb-update', 'register', (ev) => {
        ev.detail.root.querySelectorAll('paper-checkbox[data-ref]').forEach((checkbox) => {
            const id = checkbox.getAttribute('data-ref');
            
            checkbox.addEventListener('change', () => {
                findPopovers(id, (ref) => {
                    if (checkbox.checked) {
                        ref.classList.add('highlight');
                    } else {
                        ref.classList.remove('highlight');
                    }
                });
            });
        });
    });

});