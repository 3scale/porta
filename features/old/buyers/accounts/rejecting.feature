@javascript
Feature: Rejecting buyer account
  In order to let know my new buyers that I don't like them
  As a provider
  I want to reject them

  Background:
    Given a provider "foo.example.com"
    And provider "foo.example.com" has multiple applications enabled
    And provider "foo.example.com" requires cinstances to be approved before use
    And provider "foo.example.com" requires accounts to be approved

    And current domain is the admin domain of provider "foo.example.com"
    And I am logged in as provider "foo.example.com"

  Scenario: Rejecting a single buyer account
    Given a pending buyer "bob" signed up to provider "foo.example.com"
    When I go to the buyer account page for "bob"
    And I press "Reject"
    Then buyer "bob" should be rejected

  Scenario: Reject button is not shown for already rejected accounts
    Given a rejected buyer "bob" signed up to provider "foo.example.com"
    When I go to the buyer account page for "bob"
    Then I should not see button to reject buyer "bob"

  Scenario: Reject button is not shown for approved accounts
    Given an approved buyer "bob" signed up to provider "foo.example.com"
    When I go to the buyer account page for "bob"
    Then I should not see button to reject buyer "bob"

  @wip
  Scenario: Rejecting buyer accounts in bulk
    When I navigate to the pending partners page
    And I check the buyers:
      | buyer      |
      | pendi_1    |
      | pendi_2    |
    And I press the button to reject the buyers
    Then I should see the confirm page before I reject the buyers:
      | buyer      |
      | pendi_1    |
      | pendi_2    |

    When I confirm to reject of the buyers
    Then the following buyers should be rejected:
      | buyer      |
      | pendi_1    |
      | pendi_2    |
    And I should see the pending partners page

