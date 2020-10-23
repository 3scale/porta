@ignore-backend
Feature: Provider sees buyer's credit card details
  In order to know as much as I can about my clients
  As a provider
  I want to see their credit card details

  Background:
    Given the year is 2010
    And a provider "foo.3scale.localhost"
    And an application plan "Basic" of provider "foo.3scale.localhost"
    And current domain is the admin domain of provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" has "finance" switch allowed
    And provider "foo.3scale.localhost" is charging
    And a buyer "alice" signed up to application plan "Basic"

  Scenario: show cc is on file
    When I log in as provider "foo.3scale.localhost"
      And buyer "alice" has last digits of credit card number "1234" and expiration date March, 2018
      And I go to the buyer accounts page
      And I follow "alice"
    Then I should see "Credit Card details are on file"
     And I should see "Card expires in: March 2018"

  Scenario: cc is not on file
    When I log in as provider "foo.3scale.localhost"
      And I go to the buyer accounts page
      And I follow "alice"
    Then I should see "Credit Card details are not stored"
