Feature: Login feature
  In order to have a better site experience
  I want to have a cool login behaviour

  Background:
    Given a provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has multiple applications enabled
      And a buyer "bob" signed up to provider "foo.3scale.localhost"

  @security
  Scenario: Buyer can log in with csrf protection enabled
    Given the current domain is foo.3scale.localhost
    When I go to the login page
     And I fill in the "bob" login data
    Then I should be logged in the Development Portal

  @recaptcha
  Scenario: Captcha is disabled
    Given the provider has bot protection disabled
     When the buyer wants to log in
     Then the captcha is not present

  @recaptcha
  Scenario: Captcha is enabled
    Given the provider has bot protection enabled
     When the buyer wants to log in
     Then the captcha is present

  @recaptcha
  Scenario: Developer can log in with Captcha enabled
    Given the provider has bot protection enabled
    And the client will not be marked as a bot
    When the developer tries to log in
    Then the page should contain "Signed in successfully"

  @recaptcha
  Scenario: Captcha rejects a bot attempt also when it sends the correct credentials
    Given the provider has bot protection enabled
    And the client will be marked as a bot
    When the developer tries to log in
    Then the developer login attempt fails
