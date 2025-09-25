describe('places page', () => {
    beforeEach('loads', () => {
        cy.visit('kontexte/orte/')
    })

    it('displays a map', () => {
        cy.get('pb-leaflet-map').should('be.visible')
    })

    it('displays app searchbar', () => {
        cy.get('#query').should('be.visible')
    })
})