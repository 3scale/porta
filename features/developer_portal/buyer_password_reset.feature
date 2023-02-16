Feature: Buyer signup
  I want to reset my password as a buyer

  Background:
    Given a provider exists
    And master has a application plan "enterprise"
    And the provider account allows signups

  @recaptcha
  Scenario: Spam protection detects suspicious behavior
    Given the provider has spam protection set to suspicious only
    When the buyer wants to reset their password
    Then 15 seconds pass
    Then the buyer doesn't need to pass the captcha after reset password form is filled wrong
    But the buyer will need to pass the captcha after reset password form is filled in too quickly