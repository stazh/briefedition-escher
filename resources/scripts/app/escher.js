/**
 * For a given start element, find the node before the next sibling matching the given selector.
 * If there is no sibling matching the selector, return the last node found.
 * 
 * @param {Node} current the start node of the range
 * @param {string} selector a selector against which found nodes should match
 */
function findEndOfRange(root, current, selector) {
    const walker = document.createTreeWalker(root);
    walker.currentNode = current;
    let last = null;
    while (walker.nextNode()) {
        if (walker.currentNode.nodeType === Node.ELEMENT_NODE && walker.currentNode.matches(selector)) {
            return walker.currentNode;
        }
        last = walker.currentNode;
    }
    return last;
}

function ancestor(node, selector) {
    let parent = node.parentNode;
    while (parent && parent !== node.getRootNode()) {
      if (parent.matches(selector)) {
        return parent;
      }
      parent = parent.parentNode;
    }
    return parent;
}

let root;

// find popovers containing the id in their data-ref attribute and call the callback for each.
function findPopovers(id, callback) {
    root.querySelectorAll(`pb-popover[data-ref="${id}"]`).forEach(callback);
}

/**
 * Transpose coordinates from x1, y1, x2, y2 to x, y, width, height
 * as required by IIIF.
 * 
 * @param {string} coordsString 
 */
function adjustCoords(coordsString) {
    const coords = coordsString.split(',');
    return [parseInt(coords[0]), parseInt(coords[1]), coords[2] - coords[0], coords[3] - coords[1]];
}

window.addEventListener('DOMContentLoaded', () => {
    const letter = document.querySelector('.letter');

    pbEvents.subscribe('pb-before-update', 'transcription', (ev) => {
        root = ev.detail.root;
        // reusable image element which will be positioned above the mouse position
        const regionImage = document.createElement('img');
        regionImage.style.display = 'block';
        regionImage.style.position = 'absolute';
        regionImage.style.zIndex = 1001;
        root.appendChild(regionImage);

        // wrap all lines into ranges
        root.querySelectorAll('br').forEach((br) => {
            const next = findEndOfRange(ancestor(br, 'p,div'), br, 'br');
            if (!next) {
                return;
            }
            const wrapper = document.createElement('span');
            wrapper.className = 'line';

            const file = br.getAttribute('data-image');
            const coords = br.getAttribute('data-coords');
            const updatedCoords = adjustCoords(coords);
            // on mouseenter, retrieve the corresponding region of the facsimile from IIIF
            wrapper.addEventListener('mouseenter', (ev) => {
                const target = ev.target;
                if (target.querySelector('br.toggle')) {
                    return false;
                }
                pbEvents.emit('pb-show-annotation', 'transcription', {
                    file,
                    coordinates: updatedCoords
                });
                // const top  = (target.offsetTop - updatedCoords[3] - 10) + 'px';
                const containerWidth = wrapper.clientWidth;
                const imgUrl = `https://media.sources-online.org/iiif/2/escher!${file}/${updatedCoords.join(',')}/full/0/default.jpg`;
                regionImage.style.display = 'none';
                const buffer = new Image();
                buffer.addEventListener('load', () => {
                    const containerRect = root.getBoundingClientRect();
                    const rects = target.getClientRects();
                    regionImage.style.top = (rects[0].top - containerRect.top - updatedCoords[3] - 10)+ 'px';
                    regionImage.style.left = (rects[0].left - containerRect.left) + 'px';
                    regionImage.style.right = (rects[0].right - containerRect.right) + 'px';
                    if (buffer.width > containerWidth) {
                        regionImage.style.width = '100%';
                        regionImage.style.height = 'auto';
                    } else {
                        regionImage.style.width = 'auto';
                        regionImage.style.height = 'auto';
                    }
                    regionImage.style.display = '';
                    regionImage.src = imgUrl;
                });
                buffer.src = imgUrl;
                
                target.classList.add('highlight-line');
            });
            wrapper.addEventListener('mouseleave', (ev) => {
                regionImage.style.display = 'none';
                ev.target.classList.remove('highlight-line');
            });
            const range = document.createRange();
            range.setStartBefore(br);
            if (next.nodeName === 'BR') {
                range.setEndBefore(next);
            } else {
                range.setEndAfter(next);
            }
            // range.surroundContents(wrapper);

            // the line may contain webcomponents like pb-popover which would be detached from the DOM
            // if we just copied nodes. Therefore we assign a serialized copy to wrapper.innerHTML, which
            // will cause nested webcomponents to be initialized.
            const contents = range.extractContents();
            const div = document.createElement('div');
            div.appendChild(contents.cloneNode(true));
            wrapper.innerHTML = div.innerHTML;
            range.insertNode(wrapper);
        });

        ev.detail.render(root);
    });

    pbEvents.subscribe('pb-update', 'transcription', (ev) => { 
        root = ev.detail.root;
        // extract letter id
        const textElem = root.querySelector('.text');
        if (textElem) {
            if (textElem.dataset.letter) {
                document.getElementById('letterId').innerHTML = textElem.dataset.letter;
            } else {
                document.getElementById('letterId').innerHTML = textElem.innerHTML;
            }
        }

        const footerLink = document.querySelector('.persistentLink');
        if (textElem && footerLink) {
            const breadcrumbs = document.querySelector('.breadcrumbs');
            const appPath = breadcrumbs.dataset.path;
            const plink = `https://briefedition.alfred-escher.ch${appPath}${textElem.dataset.letter}`;
            footerLink.href = plink;
            footerLink.innerHTML = plink;
        }
    });

    pbEvents.subscribe('pb-refresh', 'nav', (ev) => {
        if (letter) {
            anime({
                targets: letter,
                opacity: 0,
                duration: 100,
                easing: 'linear'
            });
        }
    });

    pbEvents.subscribe('pb-end-update', 'transcription', (ev) => {
        if (letter) {
            anime({
                targets: letter,
                opacity: 1,
                duration: 800,
                easing: 'linear'
            });
        }
    });

    pbEvents.subscribe('pb-update', 'header', (ev) => { 
        root = ev.detail.root;

        const corresp = root.querySelector('nav.corresp');
        if (corresp) {
            ['prev', 'next', 'prev-in-edition', 'next-in-edition'].forEach((type) => {
                const pbLink = document.getElementById(type);
                const span = corresp.querySelector(`.${type}`);
                if (span && pbLink) {
                    pbLink.style.display = '';
                    const path = span.dataset.path;
                    if (pbLink) {
                        pbLink.path = path;
                    }
                } else if (pbLink) {
                    pbLink.style.display = 'none';
                }
            });
        }
        const correspTitle = root.querySelector('.correspondence');
        if (correspTitle) {
            document.getElementById('correspondence').innerHTML = correspTitle.innerHTML;
        }

        const letterTitle = root.querySelector('.letter-title');
        if (letterTitle) {
            document.title = letterTitle.innerText;
        }
    });

    // wait until register content has been loaded
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

    const timelineChanged = (ev) => {
        let correspondent;
        document.querySelectorAll('#correspondence [data-ref]').forEach((elem) => {
            const ref = elem.getAttribute('data-ref');
            if (ref !== 'Escher (vom Glas) Alfred') {
                correspondent = ref;
            }
        });
        window.location = `./?dates=${ev.detail.categories.join(';')}&facet-correspondent=${correspondent}`;
    };
    pbEvents.subscribe('pb-timeline-date-changed', 'timeline', timelineChanged);
    pbEvents.subscribe('pb-timeline-daterange-changed', 'timeline', timelineChanged);
    pbEvents.subscribe('pb-timeline-reset-selection', 'timeline', () => {
        pbEvents.emit('pb-search-resubmit', 'docs', { params: { dates: null }});
    });

    /**
     * Trigger for print icon (only available in TEI document templates)
     * Will redirect to a printable HTML page of the document
     */
    const openPrintDialog = document.getElementById("openPrintDialog");
    if (openPrintDialog) {
        openPrintDialog.addEventListener( "click", () => {
            let currentOrigin = window.location.origin.toString();
            let currentPath = window.location.pathname.toString();
            let docPath = currentPath.replace( /^.*\/([^/]+\/.*)$/, "$1" );
            let urlPart = currentPath.replace( /^(.*)\/[^/]+\/.*$/, "$1" );
            let updatedDocPath = docPath.replace( "/", "%2F" );
            let newUrl = `${urlPart}/api/document/${updatedDocPath}/print?odd=escher.odd`;
            console.log( newUrl );
            window.open( newUrl );
        } )
    }
});