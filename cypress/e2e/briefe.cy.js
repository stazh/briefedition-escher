describe('briefe page', () => {
    beforeEach('loads', () => {
        cy.visit('briefe')
    })

    it('displays app header', () => {
        cy.get('app-header')
            .should('be.visible')
    })
    
    it('display Schlagwort facets', () => {
        cy.get('.facet-keyword')
            .should('exist')
            .first()
            .should('contain.text', 'Schlagwort')
    })

    it('displays menubar', () => {
        cy.get('.menubar')
            .should('be.visible')
    })

    it('displays toolbar', () => {
        cy.get('.toolbar')
            .should('be.visible')
    })

    it('displays timeline', () => {
        cy.get('.timeline')
            .should('be.visible')
    })

    it('displays documents', () => {
        cy.get('.documents')
            .should('be.visible')
    })        
    it('displays document', () => {
        cy.get('.document')
            .should('be.visible', "document should be visible")
            .should('have.length',10, "there should be 10 documents listed")
    })        
    
})