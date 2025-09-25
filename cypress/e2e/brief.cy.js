describe('briefe page', () => {
    beforeEach('loads', () => {
        cy.visit('briefe/B0017')
    })

    it('displays app header', () => {
        cy.get('app-header')
            .should('be.visible')
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
        cy.get('pb-timeline')
            .should('be.visible')
    })

    it('displays Korrespondenten', () => {
        cy.get('.content .tei-head3')
            .eq(0)
            .should('be.visible')
            .should('contain.text', 'Korrespondenten')
    })
    it('displays correspondent Alfred Escher', () => {
        cy.get('.content .tei-persName2')
            .eq(0)
            .should('be.visible')
            .should('contain.text', 'Alfred Escher')
    })
    it('displays correspondent Oswald Heer', () => {
        cy.get('.content .tei-persName2')
            .eq(1)
            .should('be.visible')
            .should('contain.text', 'Oswald Heer')
    })

    it('displays Briefdatum', () => {
        cy.get('.content .tei-head3')
            .eq(1)
            .should('be.visible')
            .should('contain.text', 'Briefdatum')
    })

    it('displays persons', () => {
        cy.get('.content .tei-head3')
            .eq(2)
            .should('be.visible')
            .should('contain.text', 'Personen')
    })

    it('displays person Heer Jakob', () => {
        cy.get('.content .tei-persName4')
            .eq(0)
            .should('exist')
            .should('contain.text', 'Heer Jakob')
    })
    it('displays person Hegetschweiler Johannes', () => {
        cy.get('.content .tei-persName4')
            .eq(1)
            .should('exist')
            .should('contain.text', 'Hegetschweiler Johannes')
    })
    it('displays places', () => {
        cy.get('.content .tei-head3')
            .eq(3)
            .should('exist')
            .should('contain.text', 'Orte')
    })

    it('displays place Alpen', () => {
        cy.get('.content .tei-placeName1')
            .eq(0)
            .should('exist')
            .should('contain.text', 'Alpen')
    })
    it('displays place Glarus', () => {
        cy.get('.content .tei-placeName1')
            .eq(1)
            .should('exist')
            .should('contain.text', 'Glarus')
    })
    it('displays place Graubünden', () => {
        cy.get('.content .tei-placeName1')
            .eq(2)
            .should('exist')
            .should('contain.text', 'Graubünden')
    })
    it('displays place Nufenen (Pass)', () => {
        cy.get('.content .tei-placeName1')
            .eq(3)
            .should('exist')
            .should('contain.text', 'Nufenen (Pass)')
    })
    it('displays place Wädenswil', () => {
        cy.get('.content .tei-placeName1')
            .eq(4)
            .should('exist')
            .should('contain.text', 'Wädenswil')
    })
})