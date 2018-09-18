Feature: Credit card details
  In order to pay for the service
  As a buyer
  I want to enter my credit card details and keep them up to date

  Background:
    Given the time is 1st June 2009
    Given a provider "foo.example.com"
      And provider "foo.example.com" is charging
      And provider "foo.example.com" has "finance" switch visible
    Given the current domain is "foo.example.com"
      And an application plan "Pro" of provider "foo.example.com"
      And a buyer "kenny" signed up to application plan "Pro"

  @wip @3D
  Scenario: Entering credit card details on the master domain
    When the current domain is "foo.example.com"
      And provider "foo.example.com" manages payments with "braintree_blue"
      And provider "master" is charging
      And provider "master" manages payments with "braintree_blue"

      And current domain is the admin domain of provider "foo.example.com"
      And I log in as provider "foo.example.com"

      And I go to the braintree credit card details page
    Then I should see button "Edit Credit Card Details"

  Scenario: Legal Links on Credit Card Details edit page on Enterprise
      And the current domain is "foo.example.com"
      And provider "foo.example.com" manages payments with "stripe"
      And provider "foo.example.com" has the following settings:
        | cc_terms_path   | lorem-terms   |
        | cc_privacy_path | ipsum-privacy |
        | cc_refunds_path | dolor-refunds |
    When I log in as "kenny" on foo.example.com
      And I follow "Settings"
      And I follow "Credit Card Details"
    Then I should see the legal terms link linking to path "lorem-terms"
      And I should see the privacy link linking to path "ipsum-privacy"
      And I should see the refunds link linking to path "dolor-refunds"

  Scenario: Credit Card Details link does not show with charging disabled
      And provider "foo.example.com" is not charging
      And the current domain is "foo.example.com"
    When I log in as "kenny" on foo.example.com
      And I go to the account page
    Then I should not see the link credit card details

  Scenario: Entering billing address
    Given a buyer without billing address "stan" signed up to application plan "Pro"
      And provider "foo.example.com" manages payments with "stripe"
     When I log in as "kenny" on foo.example.com
      And I follow "Settings"
      And I follow "Credit Card Details"
      And I follow "Edit billing address"
     Then I should see "Billing Address"

  Scenario: Entering credit card details on a provider domain
    Given the current domain is foo.example.com
      And provider "foo.example.com" manages payments with "stripe"
      And buyer "kenny" has last digits of credit card number "1234" and expiration date March, 2018
   When I log in as "kenny" on foo.example.com
    And I follow "Settings"
    And I follow "Credit Card Details"
    And I follow "Edit billing address"

    And I should see "Billing Address"

    When I fill in "Contact / Company Name" with "comp"
    And I fill in "Address" with "C/LLacuna 162"
    And I fill in "City" with "Barcelona"
    And I select "Spain" from "Country"
    And I fill in "ZIP / Postal Code" with "08080"
    And I fill in "Phone" with "+34123123212"
    And I press "Save"

    Then the current domain should be foo.example.com
    And I should see "Credit card number"
    And I should see "XXXX-XXXX-XXXX-1234"
    And I should see "Expiration date"
    And I should see "March, 2018"
