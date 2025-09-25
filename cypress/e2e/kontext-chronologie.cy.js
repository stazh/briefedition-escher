describe('landing page', () => {
  beforeEach('loads', () => {
    cy.visit('kontexte/chronologie/')
      cy.intercept('GET', '**/api/parts/**').as('getParts')
      cy.intercept('GET', '**/api/document/**').as('getDocument')
  })

  it('should display h1', () => {
    cy.get('.transcript h1')
      .should('be.visible')
      .should('contain', 'Alfred Escher – Chronologie')
  })

  it('should start with 20.02.1819', () => {
    cy.get('table > tbody > tr')
      .eq(0)
      .find('td')
      .first()
      .should('be.visible')
      .should('contain', '20.02.1819')
  })

  it('should end with 06.12.1882', () => {
    cy.get('table > tbody > tr')
      .last()
      .find('td')
      .first()
      .should('exist')
      .should('contain', '06.12.1882')
  })
  
})