Feature: Finance switch
  The value of the finance switch
  Controls the Finance feature

  Background:
    Given an application plan "plus" of provider "master"
      And a provider "foo.3scale.localhost"
      And current domain is the admin domain of provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has prepaid billing enabled

  Scenario: Finance tab works if enabled
    Given provider "foo.3scale.localhost" has "finance" switch allowed
    When I log in as provider "foo.3scale.localhost"
      And I follow "Billing"
    Then I should be on the finance page

  Scenario: Finance tab unavailable if disabled
    Given provider "foo.3scale.localhost" has "finance" switch denied
    When I log in as provider "foo.3scale.localhost"
    Then I should not see "Billing" in the audience dashboard widget
    When I follow "0 Accounts"
    Then I should not see "Billing" in the main menu

  Scenario: Finance page forbidden if finance not enabled
    Given provider "foo.3scale.localhost" has "finance" switch denied
    When I log in as provider "foo.3scale.localhost"
    And I want to go to the finance page
    Then I should get access denied

  Scenario: Buyer does not see finance links if finance is hidden
    Given an application plan "plan" of provider "foo.3scale.localhost"
      And a buyer "buyer" signed up to application plan "plan"
    Given provider "foo.3scale.localhost" has "finance" switch allowed
    When I log in as "buyer" on "foo.3scale.localhost"
      And I go to the account page
    Then I should not see link to the invoices page
      And I should not see "Credit Card Details"
