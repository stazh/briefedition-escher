describe('people page', () => {
    beforeEach('loads', () => {
        cy.visit('kontexte/personen/')
    })

    it('displays a searchbar', () => {
        cy.get('paper-input').should('be.visible')
    })

    it('displays list of people', () => {
        cy.get('pb-split-list').should('be.visible')
    })
})