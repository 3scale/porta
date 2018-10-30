Feature: Finance switch
  The value of the finance switch
  Controls the Finance feature

  Background:
    Given an application plan "plus" of provider "master"
      And a provider "foo.example.com"
      And current domain is the admin domain of provider "foo.example.com"
      And provider "foo.example.com" has prepaid billing enabled

  Scenario: Finance tab works if enabled
    Given provider "foo.example.com" has "finance" switch allowed
    When I log in as provider "foo.example.com"
      And I follow "Billing"
    Then I should be on the finance page

  Scenario: Finance tab unavailable if disabled
    Given provider "foo.example.com" has "finance" switch denied
    When I log in as provider "foo.example.com"
    Then I should not see "Billing" in the audience dashboard widget
    When I follow "Accounts"
    Then I should not see "Billing" in the main menu

  Scenario: Finance page forbidden if finance not enabled
    Given provider "foo.example.com" has "finance" switch denied
    When I log in as provider "foo.example.com"
    And I want to go to the finance page
    Then I should get access denied

  Scenario: Buyer does not see finance links if finance is hidden
    Given an application plan "plan" of provider "foo.example.com"
      And a buyer "buyer" signed up to application plan "plan"
    Given provider "foo.example.com" has "finance" switch allowed
    When I log in as "buyer" on foo.example.com
      And I go to the account page
    Then I should not see link to the invoices page
      And I should not see "Credit Card Details"
