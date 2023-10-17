@javascript @email-configurations
Feature: Email configurations
  Custom email domain can be configured by the user without any interaction on the 3scale side required.
  For all emails delivered to non-custom domains the SendGrid integration works well and does not need to be changed.
  Exposing the SMTP configuration to the user on a per Tenant basis would make this an easy and scalable solution.

  Rule: Master
    Background:
      Given master is the provider
      And master admin is logged in
      And I have enough email configs to fill many pages

    Scenario: Email configurations index sorting
      When I go to the email configurations page
      Then the latest email configurations are listed first

    Scenario: Email configurations index pagination
      When I go to the email configurations page
      Then I should not see all my email configurations
      And I should be able to go to the next page

    @search
    Scenario: Email configurations index filtering
      When I go to the email configurations page
      Then I should be able to filter them by email and user name

    Scenario: Create an email configurations
      When I go to the email configurations page
      And I follow "Add an Email configuration"
      Then I should be able to create an email configuration

  Rule: Provider
    Background:
      Given a provider "foo.3scale.localhost"
      And the current domain is "foo.3scale.localhost"

    Scenario: Email configurations are not accessible
      When I go to the email configurations page
      Then I should see "Not Found"
