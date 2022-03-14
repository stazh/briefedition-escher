# Digitale Briefedition Alfred Escher

https://www.briefedition.alfred-escher.ch/briefe/

Data and [TEI Publisher App](https://teipublisher.com/index.html) of the edition which was relaunched 2022. 

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/80x15.png" /></a><br />Texts and data are licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.

The app is licensed under [GNU General Public License](https://www.gnu.org/licenses/gpl-3.0.en.html)

## Development Notes

### Data Conversion

The original XML data was converted to TEI using the XQuery modules available in [modules/conversion](modules/conversion/). Letters were first transformed through the [main conversion script](modules/conversion/letters.xql) and then [post-processed](modules/conversion/correspContext.xql) to add a tei:correspDesc to the header, indicating the next and previous letters in the correspondence. Finding out which letters are part of a correspondence would otherwise be too time consuming. Based on this, timeline information was later extracted in a [separate step](modules/conversion/timeline.xql).

The names of the other modules correspond to the type of data they process, i.e. places, people, abbreviations, commentaries and the bibliography.

With all data processed, another auxiliary file was created to provide fast access to [letter titles](modules/conversion/titles.xql). Those are displayed in various popups, so collecting them on the fly would be expensive.

### Application

The app was initially generated from TEI Publisher 7 and updated later to keep up with latest Publisher developments. Following general recommendations, server-side functionality is implemented in XQuery files directly below [modules](modules/). 

The goal was to preserve backwards compatibility for all URLs as much as possible. To reflect the different browsing contexts for `/briefe`, `/kontexte` etc., new endpoints were added to [custom-api.json](modules/custom-api.json) and implemented in [custom-api.xql](modules/custom-api.xql) and (in some cases) [app.xql](modules/app.xql) - unless the request is forwarded to standard TEI Publisher endpoints.

In the TEI sources, letters are identified by an @xml:id following the pattern "K_nnnnn", while users would access a letter using an ID like "Bnnnnnn". To retain this behaviour in a backwards-compatible way, the function `$config:get-document` was overwritten to translate the @xml:id.

All transformations from TEI to HTML are done via [escher.odd](resources/odd/escher.odd), using only three small extension functions in XQuery in [ext-html.xql](modules/ext-html.xql) and [ext-common.xql](modules/ext-common.xql).

Most of the webdesign is determined by [escher-theme.css](resources/css/escher-theme.css), which overwrites some of the TEI Publisher default styles from [theme.css](resources/css/theme.css). The latter can thus be easily updated to newer versions of Publisher. Additional, page specific styling is applied within the corresponding [HTML templates](templates/).

For browsing people and places, a new web component, `pb-split-list` was implemented. Likewise, `pb-leaflet-map` and `pb-timeline` were extended. All three were contributed to the tei-publisher-components distribution.

Custom [javascript functions](resources/scripts/app/escher.js) are used to:

* show facsimile regions if user mouse overs a line in the diplomatic view
* handle letter-by-letter navigation links
* react to user interactions with the timeline component
* show the CSS print view in a separate tab/window