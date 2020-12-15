Feature: Onboarding Wizard
  In order to onboard customers faster,
  we want them to go through a wizard,
  that will configure their API and deploy sandbox proxy.

  Background:
    Given the master account allows signups

  @emails
  Scenario: Provider goes through the wizard
    Given a provider signs up and activates his account
    When user starts the onboarding wizard
     And goes to Add a Backend page
     And adds the echo Backend
     And goes to Add a Product page
     And adds the echo Product
     And goes to Connect page
     And adds a path
     And goes to the request page
     And sends the test request
     And goes to what's next
    Then goes to API page
