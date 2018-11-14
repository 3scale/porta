@security
Feature: Buyer accounts management security
  In order to not allow anyone to mess with the buyer accounts
  There should be some access rules

  Background:
  Given a provider "foo.example.com"
    And provider "foo.example.com" has multiple applications enabled
    And a buyer "bob" signed up to provider "foo.example.com"

  Scenario: Anonymous users can't manage buyer accounts
    And current domain is the admin domain of provider "foo.example.com"
    When I am not logged in
    And I go to the buyer accounts page
    Then I should be on the provider login page

    When I go to the new buyer account page
    Then I should be on the provider login page

    When I go to the buyer account page for "bob"
    Then I should be on the provider login page

    When I go to the buyer account edit page for "bob"
    Then I should be on the provider login page

    When I do a HTTP request to create new buyer with name "secret agent"
    Then I should be on the provider login page
    And there should be no buyer "secret agent"

    When I do a HTTP request to update buyer "bob" changing the organization name to "carl"
    Then I should be on the provider login page
    And there should be no buyer "carl"
    But there should be a buyer "bob"

    When I do a HTTP request to delete buyer "bob"
    Then I should be on the provider login page
    And there should be a buyer "bob"

  @allow-rescue
  Scenario: Non-admins can't manage buyer accounts
    Given an active user "daniel" of account "foo.example.com"
    When I log in as provider "daniel"
    When I go to the buyer accounts page
    Then I should be denied the access
    # Then I should not see link "Create new buyer account"
    # And I should see link "bob"
    # And I should not see link to the buyer account edit page for "bob"
    # And I should not see button to delete buyer "bob"

    When I go to the new buyer account page
    Then I should be denied the access

    When I go to the buyer account edit page for "bob"
    Then I should be denied the access

    When I do a HTTP request to create new buyer with name "jack"
    Then I should be denied the access
    And there should be no buyer "jack"

    When I do a HTTP request to update buyer "bob" changing the organization name to "mike"
    Then I should be denied the access
    And there should be no buyer "mike"
    But there should be a buyer "bob"

    When I do a HTTP request to delete buyer "bob"
    Then I should be denied the access
    And there should be a buyer "bob"

    # TODO: approve and reject

  @allow-rescue
  Scenario: Providers can't manage buyer's of other providers
    Given a provider "xyz.example.com"
    And current domain is the admin domain of provider "xyz.example.com"

    When I log in as provider "xyz.example.com"
    And I navigate to the accounts page
    Then I should not see "bob"

    When I go to the buyer account edit page for "bob"
    Then I should get 404

    When I do a HTTP request to update buyer "bob" changing the organization name to "mike"
    Then I should get 404
    And there should be no buyer "mike"
    But there should be a buyer "bob"

    When I do a HTTP request to delete buyer "bob"
    Then I should get 404
    And there should be a buyer "bob"
