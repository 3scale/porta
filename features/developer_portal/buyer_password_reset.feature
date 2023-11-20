Feature: Buyer signup
  A buyer wants to reset their password

  Background:
    Given a provider exists
    And master has a application plan "enterprise"
    And the provider account allows signups

  @recaptcha
  @javascript
  Scenario: Spam protection detects suspicious behavior
    Given the provider has spam protection set to suspicious only
    When the buyer wants to reset their password
    Then the buyer won't need to pass the captcha after reset password form is filled in incorrectly
    But the buyer will need to pass the captcha after reset password form is filled in suspiciously

  @recaptcha
  @javascript
  Scenario: Spam protection detects multiple attempts in less than a minute
    Given the provider has spam protection set to suspicious only
    When the buyer wants to reset their password
    Then the buyer won't need to pass the captcha after reset password form is filled in correctly
    Then the buyer won't need to pass the captcha after reset password form is filled in again
    But the buyer will need to pass the captcha after reset password form is filled in again
