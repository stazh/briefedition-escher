describe('landing page', () => {
  beforeEach('loads', () => {
    cy.visit('/home.html')
  })

  it('displays app header', () => {
    cy.get('app-header')
      .should('be.visible')
  })
  it('displays h1 header', () => {
    cy.get('h1')
      .should('be.visible')
      .should('contain.text', 'Herzlich willkommen bei der Alfred Escher-Briefedition')
  })
  it('displays quote box', () => {
    cy.get('.quote')
      .should('exist')
  })
  it('displays briefe box', () => {
    cy.get('.briefe')
      .should('be.visible')
  })
  it('displays personen box', () => {
    cy.get('.personen')
      .should('be.visible')
  })
  it('displays orte box', () => {
    cy.get('.orte')
      .should('be.visible')
  })
  it('displays facsimile box', () => {
    cy.get('.facsimile')
      .should('exist')
  })

  it('displays feature image', () => {
    cy.get('img').should('be.visible')
  })

  it('displays app footer', () => {
    cy.get('footer').should('be.visible')
  })
})