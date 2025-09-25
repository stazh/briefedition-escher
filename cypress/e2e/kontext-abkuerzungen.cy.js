describe('places page', () => {
    beforeEach('loads', () => {
        cy.visit('kontexte/abkurzungen/Quellen/A')
    })

    it('display h3 with content A', () => {
        cy.get('h3')
            .should('be.visible')
            .should('contain.text', 'A')
    })
})