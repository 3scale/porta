Feature: Login feature
  In order to have a better site experience
  I want to have a cool login behaviour

  Background:
    Given a provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" has multiple applications enabled
    And a buyer "bob" signed up to provider "foo.3scale.localhost"
    And the current domain is "foo.3scale.localhost"

  @security
  Scenario: Buyer can log in with csrf protection enabled
    When I go to the login page
    And I fill in the "bob" login data
    Then I should be logged in the Development Portal

  @recaptcha
  Scenario: Captcha is disabled
    Given provider "foo.3scale.localhost" has "spam protection level" set to "none"
    When I go to the login page
    Then I should not see the captcha
    And I fill in the "bob" login data
    And I should be logged in the Development Portal

  @recaptcha
  Scenario: Captcha is forced
    Given provider "foo.3scale.localhost" has "spam protection level" set to "captcha"
    When I go to the login page
    Then I should see the captcha

  @recaptcha
  Scenario: Spam check fails (because of fast fill and no js)
    Given provider "foo.3scale.localhost" has "spam protection level" set to "auto"
    And I go to the login page
    When timestamp spam check will return probability 1
    And I fill in the "bob" login data
    Then I should see the captcha
