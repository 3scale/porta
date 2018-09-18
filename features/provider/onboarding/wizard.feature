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
     And adds the echo api
     And sends the test request
     And goes to what's next
    Then goes to API page
