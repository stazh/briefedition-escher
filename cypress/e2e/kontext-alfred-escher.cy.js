describe('landing page', () => {
  beforeEach('loads', () => {
    cy.visit('kontexte/alfred-escher')
      cy.intercept('GET', '**/api/parts/**').as('getParts')
      cy.intercept('GET', '**/api/document/**').as('getDocument')
  })

  it.only('displays body', () => {
    cy.get('body')
      .should('be.visible')
  })
  it.only('displays h1', () => {
    cy.get('.content h1')
      .should('be.visible')
      .should('contain', 'Alfred Escher – Schöpfer der modernen Schweiz')
  })
  it.only('displays h2 Politisches Engagement', () => {
    cy.get('.content h2')
      .eq(0)
      .should('exist')
      .should('contain', 'Politisches Engagement')
  })
  it.only('displays h2 Eschers Gründungen', () => {
    cy.get('.content h2')
      .eq(1)
      .should('exist')
      .should('contain', 'Eschers Gründungen')
  })
  it.only('displays h2 Das «System Escher»', () => {
    cy.get('.content h2')
      .eq(2)
      .should('exist')
      .should('contain', 'Das «System Escher»')
  })
  it.only('displays h2 Grösster Erfolg: Die Gotthardbahn', () => {
    cy.get('.content h2')
      .eq(3)
      .should('exist')
      .should('contain', 'Grösster Erfolg: Die Gotthardbahn')
  })
  it.only('displays h2 Escher, ein Anachronismus', () => {
    cy.get('.content h2')
      .eq(4)
      .should('exist')
      .should('contain', 'Escher, ein Anachronismus')
  })
  it.only('displays h2 Der Höhepunkt als Niederlage', () => {
    cy.get('.content h2')
      .eq(5)
      .should('exist')
      .should('contain', 'Der Höhepunkt als Niederlage')
  })

  it.only('displays h2 Politisches Engagement', () => {
    cy.get('#toc h2')
      .eq(0)
      .should('exist')
      .should('contain', 'Politisches Engagement')
  })
  it.only('displays h2 Eschers Gründungen', () => {
    cy.get('#toc h2')
      .eq(1)
      .should('exist')
      .should('contain', 'Eschers Gründungen')
  })
  it.only('displays h2 Das «System Escher»', () => {
    cy.get('#toc h2')
      .eq(2)
      .should('exist')
      .should('contain', 'Das «System Escher»')
  })
  it.only('displays h2 Grösster Erfolg: Die Gotthardbahn', () => {
    cy.get('#toc h2')
      .eq(3)
      .should('exist')
      .should('contain', 'Grösster Erfolg: Die Gotthardbahn')
  })
  it.only('displays h2 Escher, ein Anachronismus', () => {
    cy.get('#toc h2')
      .eq(4)
      .should('exist')
      .should('contain', 'Escher, ein Anachronismus')
  })
  it.only('displays h2 Der Höhepunkt als Niederlage', () => {
    cy.get('#toc h2')
      .eq(5)
      .should('exist')
      .should('contain', 'Der Höhepunkt als Niederlage')
  })  
})