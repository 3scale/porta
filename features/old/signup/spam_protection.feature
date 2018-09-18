@recaptcha
Feature: Spam protection for buyer signup
  In order to get rid of spam accounts
  As a provider
  I want to protect buyer signup with spam protection and captcha

  Background:
    Given a provider "foo.example.com"
      And a account plan "Tier-1" of provider "foo.example.com"
      And provider "foo.example.com" has "spam protection level" set to "auto"

      And a default service of provider "foo.example.com" has name "api"
      And a service plan "Gold" for service "api" exists
      And an application plan "iPhone" of service "api"

      And the current domain is foo.example.com

  Scenario: Captcha is disabled
    Given provider "foo.example.com" has "spam protection level" set to "none"
    When I go to the sign up page
    Then I should not see the captcha
     And I fill in the invalid signup fields
     And I should not see the captcha
     And I fill in the signup fields as "hugo"
     And I should not see the captcha

  Scenario: Captcha is forced
    Given provider "foo.example.com" has "spam protection level" set to "captcha"
    When I go to the sign up page
    Then I should see the captcha

  Scenario: Spam check fails (because of fast fill and no js)
    When I go to the sign up page
    Then I should not see the captcha
    When timestamp spam check will return probability 1
     And I fill in the signup fields as "hugo"
    Then I should see the captcha

  Scenario: Spam check passes (because of time)
    When I go to the sign up page
     And 10 seconds pass
     And I fill in the signup fields as "hugo"
    Then I should see the registration succeeded

  @javascript
  Scenario: Spam check passes (because of javascript)
     When I go to the sign up page
      And I fill in the signup fields as "hugo"
     Then I should see the registration succeeded

  @javascript
  Scenario: Spam check fails (because of honeypot)
     When I go to the sign up page
      And I check hidden spam checkbox
      And I fill in the signup fields as "hugo"
     Then I should see the captcha
