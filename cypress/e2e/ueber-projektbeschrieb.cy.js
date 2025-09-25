describe('places page', () => {
    beforeEach('loads', () => {
        cy.visit('uber-die-edition/projektbeschrieb')
    })

    it('display active', () => {
        cy.get('h1')
            .should('be.visible')
            .should('contain.text', 'Projektbeschrieb')
    })
    
})
