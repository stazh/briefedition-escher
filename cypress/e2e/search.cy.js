describe('places page', () => {
    beforeEach('loads', () => {
        cy.visit('search.html?query=escher')
    })

    it('display h3 Dokumenttyp', () => {
        cy.get('#facets h3')
            .should('be.visible')
            .should('contain.text', 'Dokumenttyp')
    })

    it('display 75 matches for Bibliographie', () => {
        cy.get('#facets table tr')
            .first()
            .find('td')
            .eq(1)
            .should('contain.text', '75')
    })
    
})
