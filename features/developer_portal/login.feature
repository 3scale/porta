@recaptcha
Feature: Login feature
  In order to have a better site experience
  I want to have a cool login behaviour

  Background:
    Given a provider "foo.3scale.localhost"
    And a buyer "bob" signed up to provider "foo.3scale.localhost"
    And the current domain is "foo.3scale.localhost"

  Rule: Recaptcha always enabled
    Background:
      Given the provider has "spam protection level" set to "captcha"

    Scenario: Spam check is present
      When I go to the login page
      Then I should see the captcha

    Scenario: Spam check passed
      When I go to the login page
      And I fill in the captcha correctly
      And I fill in the "bob" login data
      Then I should be logged in the Developer Portal

    Scenario: Spam check did not pass
      When I go to the login page
      And I fill in the captcha incorrectly
      And I fill in the "bob" login data
      Then I should see "Spam protection failed."
      And I should not be logged in

  Rule: Recaptcha sometimes enabled
    Background:
      Given the provider has "spam protection level" set to "auto"

    Scenario: Spam check required after failed login
      Given I go to the login page
      And I should not see the captcha
      When I fill in the "wrong_user" login data
      Then I should see "Incorrect email or password. Please try again."
      And I should see the captcha
      Then I fill in the captcha correctly
      And I fill in the "bob" login data
      And I should be logged in the Developer Portal

  Rule: Recaptcha disabled
    Background:
      Given the provider has "spam protection level" set to "none"

    Scenario: Captcha is not required to log in
      Given I go to the login page
      And I should not see the captcha
      When I fill in the "wrong_user" login data
      Then I should see "Incorrect email or password. Please try again."
      And I should not see the captcha
      And I fill in the "bob" login data
      And I should be logged in the Developer Portal
