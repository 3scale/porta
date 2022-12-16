Feature: Invoice lifecycle
  In order to have be have details about billing process
  As a buyer
  I want to see the whole invoice lifecycle

  Background:
    Given a provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" is charging its buyers

      And an application plan "PaidAsInLunch" of provider "foo.3scale.localhost" for 31 monthly
      And the time is 29th May 2009
      And a buyer "alice" signed up to application plan "PaidAsInLunch"
      And I log in as "alice" on foo.3scale.localhost

  @commit-transactions
  Scenario: Normal postpaid life-cycle
    When buyer "alice" has a valid credit card
     And I see my invoice from "May, 2009" is "Pending" on 3rd June 2009
     And I see my invoice from "May, 2009" is "Paid" on 5th June 2009

  @commit-transactions
  Scenario: All charging fails
   Given buyer "alice" has a valid credit card with no money

    When the time flies to 5th June 2009
    Then I see my invoice from "May, 2009" is "Unpaid"

    When the time flies to 8th June 2009
    Then I see my invoice from "May, 2009" is "Unpaid"

    When the time flies to 11th June 2009
    Then I see my invoice from "May, 2009" is "Failed"
