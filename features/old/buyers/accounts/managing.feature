Feature: Buyer accounts management
  In order to have control over the accounts of my buyers
  As a provider
  I want to be able to manage the accounts

  Background:
    Given a published plan "Basic" of provider "Master account"
    And a provider "foo.example.com" signed up to plan "Basic"
    And provider "foo.example.com" has multiple applications enabled
    And a buyer "Bob's Apps" signed up to provider "foo.example.com"

    And current domain is the admin domain of provider "foo.example.com"
    And I am logged in as provider "foo.example.com"

#TODO scenario to check that to create a buyer account the buyer needs a published
# account plan

  Scenario: Creation of buyer accounts (even without legal terms)
    Given provider "foo.example.com" has no legal terms
    When I go to the buyer accounts page
     And I follow the link to create a new buyer account

    When I fill in "Organization/Group Name" with "Alice's Web Widgets"
      And I fill in "Username" with "alice"
      And I fill in "Email" with "alice@web-widgets.com"
      And I press "Create"
    Then I should see "Account" in a header
      And I should see "Alice's Web Widgets"

      And account "Alice's Web Widgets" should be approved
      And user "alice" should be active
      But "alice@web-widgets.com" should receive no emails


  Scenario: Can't create buyer account if multiple applications are disabled
    Given provider "foo.example.com" has multiple applications disabled
    When I go to the buyer accounts page
    Then I should not see link "Create new buyer account"

  Scenario: Buyer account details
    When I go to the buyer accounts page
    And I follow "Bob's Apps"
    Then I should see "Account" in a header
    And I should see link "Edit"

  Scenario: Editing buyer accounts from the account page
    When I go to the buyer account page for "Bob's Apps"
    And I follow "Edit"
    Then I should see link "Delete"
    And I fill in "Organization/Group Name" with "Bob's Web Stuff"
    And I press "Update Account"
    Then I should see "Bob's Web Stuff"
    But I should not see "Bob's Stuff"

  Scenario: In multiple application mode, shows number of applications per buyer account
    Given a default application plan of provider "foo.example.com"
    And a buyer "Alice's Widgets" signed up to provider "foo.example.com"
    And buyer "Bob's Apps" has 4 applications
    And buyer "Alice's Widgets" has 2 applications

    When I go to the buyer accounts page
    Then I should see "4" in the "Apps" column and "Bob's Apps" row
    And I should see "2" in the "Apps" column and "Alice's Widgets" row

  Scenario: In single applications mode, does not show the applications column
    Given a default application plan of provider "foo.example.com"
    And provider "foo.example.com" has multiple applications disabled
    And buyer "Bob's Apps" has 1 application

    When I go to the buyer accounts page
    Then I should not see "Apps" column in the buyer accounts table
