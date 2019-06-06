@javascript
Feature: Credit card details
  In order to pay for the service
  As a provider
  I want to enter my credit card details and keep them up to date

  Background:
    Given the time is 1st June 2009
    Given a provider "foo.example.com"
    And provider "foo.example.com" doesn't have billing address

    Given current domain is the admin domain of provider "foo.example.com"
      And provider "master" has billing enabled
      And provider "master" has testing credentials for braintree
    And I log in as provider "foo.example.com"

  Scenario: Legal Links on Credit Card Details edit page
      Given provider "master" has the following settings:
        | cc_terms_path   | lorem-terms   |
        | cc_privacy_path | ipsum-privacy |
        | cc_refunds_path | dolor-refunds |

      And I go to the provider braintree credit card details page
      Then I should see the legal terms link linking to path "lorem-terms"
      And I should see the privacy link linking to path "ipsum-privacy"
      And I should see the refunds link linking to path "dolor-refunds"

  @braintree
  Scenario: Entering credit card details on a provider domain
    Given provider "foo.example.com" has last digits of credit card number "1234" and expiration date March, 2018
    And provider "foo.example.com" has valid personal details
      And Braintree is stubbed to accept credit card
    When I go to the provider braintree edit credit card details page

    When I fill in "First Name" with "Bender"
     And I fill in "Last Name" with "Rodriguez"
     And I fill in "Number" with "4111111111111111"
     And I fill in "Expiration Date (MM/YY)" with "12/22"
     And I fill in "Cvv" with "123"
     And I fill in "Company" with "comp"
     And I fill in "Street Address" with "C/LLacuna 162"
     And I fill in "City" with "Barcelona"
     And I select "Spain" from "Country"
     And I fill in "ZIP / Postal Code" with "08080"
     And I fill in "Phone" with "+34123123212"
     And I press "Save"

   Then the current domain should be admin.foo.example.com
    And I should see "Credit card number"
    And I should see "XXXX-XXXX-XXXX-1111"
    And I should see "Expiration date"
    And I should see "December 2018"

  Scenario: Credit card storage fails

    Given provider "foo.example.com" has valid personal details
    And Braintree is stubbed to not accept credit card
    When I go to the provider braintree edit credit card details page

    When I fill in "First Name" with "Bender"
     And I fill in "Last Name" with "Rodriguez"
     And I fill in "Number" with "4111111111111112"
     And I fill in "Expiration Date (MM/YY)" with "12/13"
     And I fill in "Cvv" with "123"
     And I fill in "Company" with "comp"
     And I fill in "Street Address" with "C/LLacuna 162"
     And I fill in "City" with "Barcelona"
     And I select "Spain" from "Country"
     And I fill in "ZIP / Postal Code" with "08080"
     And I fill in "Phone" with "+34123123212"
     And I press "Save"
   Then the current domain should be admin.foo.example.com
    And I should see "Credit card number is invalid"
    And I should be on the provider braintree edit credit card details page
