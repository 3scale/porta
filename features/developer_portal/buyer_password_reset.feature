Feature: Buyer signup
  I want to reset my password as a buyer

  Background:
    Given a provider exists
    And the default product of provider "master" has name "Master API"
    And the following application plan:
      | Product    | Name       |
      | Master API | enterprise |
    And the provider has bot protection enabled
    And the provider account allows signups

  @recaptcha
  Scenario: Bot protection doesn't detect the client as a bot
    Given the client will be marked as a bot
    When the buyer wants to reset their password
    And the buyer fills in the form
    Then the page should contain "Bot protection failed."

  @recaptcha
  Scenario: Bot protection doesn't detect the client as a bot
    Given the client won't be marked as a bot
    When the buyer wants to reset their password
    And the buyer fills in the form
    Then the page should contain "A password reset link will be sent"
