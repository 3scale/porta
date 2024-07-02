@javascript
Feature: Login feature
  In order to protect the admin login screen from brute force attacks
  I want to detect bots with ReCaptcha V3

  Background:
    Given a provider "foo.3scale.localhost"

  @recaptcha
  Scenario: Captcha is disabled
    Given the master provider has bot protection disabled
    When the provider wants to log in
    Then the captcha is not present

  @recaptcha
  Scenario: Captcha is enabled
    Given the master provider has bot protection enabled
    When the provider wants to log in
    Then the captcha is present

  @recaptcha
  Scenario: Provider can log in with Captcha enabled
    Given the master provider has bot protection enabled
    And the client will not be marked as a bot
    When the provider tries to log in
    Then the current page is the provider dashboard

  @recaptcha
  Scenario: Captcha rejects a bot attempt also when it sends the correct credentials
    Given the master provider has bot protection enabled
    And the client will be marked as a bot
    When the provider tries to log in
    Then the provider login attempt fails
