describe('places page', () => {
    beforeEach('loads', () => {
        cy.visit('kontexte/bibliographie/Escheriana/Alle')
    })

    it('display active', () => {
        cy.get('.active')
            .should('be.visible')
            .should('contain.text', 'Escheriana')
    })
    
    it('display bibentry', () => {
        cy.get('.bibentry')
            .should('be.visible')
            .find('h3')
            .should('contain.text', 'A')
    })
})
