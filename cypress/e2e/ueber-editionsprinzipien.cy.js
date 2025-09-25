describe('places page', () => {
    beforeEach('loads', () => {
        cy.visit('uber-die-edition/editionsprinzipien')
    })

    it('display active', () => {
        cy.get('h1')
            .should('be.visible')
            .should('contain.text', 'Editionsprinzipien')
    })
    
})
