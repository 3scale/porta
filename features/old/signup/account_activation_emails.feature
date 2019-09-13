@emails
Feature: Account Activation Emails on Sign Up of enterprise buyers
  In order to have my partners
  Properly messaged to activate their accounts
  I want my account activation emails to be awesome

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" has multiple applications enabled
      And provider "foo.example.com" has plans already ready for signups
      And provider "foo.example.com" has "skip_email_engagement_footer" switch denied

  Scenario: Default account activation email
    Given the current domain is foo.example.com

      When someone signs up with the email "user@example.com"
      Then "user@example.com" should receive the default account activation email with viral footer applyed

    Given provider "foo.example.com" has "skip_email_engagement_footer" switch visible
      When someone signs up with the email "anotheruser@example.com"
      Then "anotheruser@example.com" should receive the default account activation email

  @javascript
  Scenario: Custom account activation email
    Given current domain is the admin domain of provider "foo.example.com"
      And I am logged in as provider "foo.example.com"
      When I go to the email templates page
      And I follow "Sign up notification for buyer"
      And I fill in the draft with "provider custom account notification email"
      And I press "Create Email Template"

    Given the current domain is foo.example.com
    When someone signs up with the email "user@example.com"
      And "user@example.com" opens the account activation email
    Then they should see "provider custom account notification email" in the email body

  @javascript
  Scenario: Custom account activation email really versioned
    Given current domain is the admin domain of provider "foo.example.com"
      And I am logged in as provider "foo.example.com"
      When I go to the email templates page

      And I follow "Sign up notification for buyer"
      And I fill in the draft with "provider custom account notification email"
      And I press "Create Email Template"

      And I follow "Sign up notification for buyer"
      And I fill in the draft with "another version of account notification email"
      And I press "Save"

    Given the current domain is foo.example.com
    When someone signs up with the email "user@example.com"
      And "user@example.com" opens the account activation email
    Then they should see "another version of account notification email" in the email body
