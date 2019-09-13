@javascript @selenium
Feature: Visual Regressions

  Background:
    Given the master account allows signups
      And the date is 2015-12-24
      And a provider signs up and activates his account
      And the provider has sample data
      And all the rolling updates features are off

  Scenario: Provider Dashboard
    Then I take a screenshot of "the provider dashboard"

  Scenario: Integration Page
    When the proxy has simple secret token
     And all the apps have simple user keys
    When I go to the service integration page
    When I toggle all inputs
    Then I take a screenshot of the current page and name it "the integration page"

  Scenario: Application Plan Page
    Then I take a screenshot of "the default application plan admin page"

  Scenario: User Edit Page
    Given a buyer "Someone" with email "someone@example.com" signs up to provider "provider"
    When I go to the buyer user edit page for "Someone"
    Then I take a screenshot of the current page and name it "the buyer user edit page for Someone"

  Scenario: Buyer Account Page
    Given a buyer "Someone" with email "someone@example.com" signs up to provider "provider"
    When I go to the buyer account page for "Someone"
    Then I take a screenshot of the current page and name it "the buyer account page for Someone"

  Scenario: Provider Account Edit Page
    Then I take a screenshot of "the provider account edit page"
    And I should see "Edit Account Details"

  Scenario: Main Developers Pages
    Given the following messages were sent to provider:
      | Subject  | Message       | Created at |
      | Hi there | How are you ? | 2015-12-31 |
    Then I take a screenshot of "the buyer accounts page"
    Then I take a screenshot of "the provider inbox page"

  Scenario: Applications Page
    Then I take a screenshot of "the applications admin page"

  Scenario: Main CMS Pages
    Given there are no recent cms templates
    Then I take a screenshot of "the cms page"
    Then I take a screenshot of "the CMS new partial page"

  Scenario: Main Settings Pages
    Given there are no recent cms templates
    Then I take a screenshot of "the email templates page"
    Then I take a screenshot of "the fields definitions index page"

  Scenario: Provider goes through the wizard
    Then  I take a screenshot of "the provider onboarding wizard page"

  @allow-rescue
  Scenario: The 404 page
    When I visit "/some-missing-page"
    Then I take a screenshot of the current page and name it "the admin portal 404 page"
