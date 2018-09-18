@wip
Feature: Provider's partners
  In order to manage my clients
  As a provider
  I want to see and edit details about them

  Background:
    Given a provider "foo.example.com"
    And an application plan "Basic" of provider "foo.example.com"
    And current domain is the admin domain of provider "foo.example.com"
    And I log in as provider "foo.example.com"

  #TODO credit card does not show nowhere anyways => looks like
  @wip
  Scenario: Credit card details on informational billing
    Given provider "foo.example.com" uses informational billing
      And a buyer "alice" signed up to application plan "Basic"
      And the buyer "alice" has activated its account
    When I follow "USERS"
      And I follow "pending"
      And I follow "alice"
    Then I should see "Credit Card Details"

    When I fill in "Card number" with "1234"
      And I select "2015" from "account_credit_card_expires_on_year"
      And I select "February" from "account_credit_card_expires_on_month"
      And I press "Save"
    # AJAX request here...
    And I go to the provider users page
    And I follow "alice"
    Then the "Card number" field should contain "1234"

  #TODO this navigation knowledge should be moved to some place where it's more expected
  @wip
  Scenario: Credit card details on prepaid billing
    Given provider "foo.example.com" has prepaid billing enabled
      And a buyer "bob" signed up to application plan "Basic"
      And the buyer "bob" has activated its account
    When I navigate to buyer "bob" details
    Then I should see buyer "bob" details page
      But I should not see "Credit Card Details"

  @wip
  Scenario: Credit card details on postpaid billing
    Given provider "foo.example.com" has postpaid billing enabled
      And a buyer "cecilia" signed up to application plan "Basic"
      And the buyer "cecilia" has activated its account
    When I navigate to buyer "cecilia" details
    Then I should see buyer "cecilia" details page
      But I should not see "Credit Card Details"
