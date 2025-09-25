describe('places page', () => {
    beforeEach('loads', () => {
        cy.visit('kontexte/uberblickskommentare/')
    })

    it('displays h1 Überblickskommentare', () => {
        cy.get('h1')
            .should('be.visible')
            .should('contain.text', 'Überblickskommentare')
    })

    it('displays last p in last .volume ', () => {
        cy.get('.volume')
            .last()
            .find('p')
            .last()
            .should('exist')
            .should('contain.text', 'Chronologie der Gotthardbahn 1863–1882')
    })
})