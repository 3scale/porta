@javascript
Feature: Wizard Billing information
  In order to provider my billing information
  As a provider
  I want a wizard to enter the required account information and credit card information

  Background:
    Given a provider is logged in
    And provider "foo.3scale.localhost" doesn't have billing address
    And provider "master" is charging its buyers with braintree
    And Braintree is stubbed for wizard
    Given master provider has the following fields defined for "Account":
      | name             | choices | label          | required | read_only | hidden |
      | org_legaladdress |         | Address        | false    | false     | false  |
      | country          |         | Country        | false    | false     | false  |
      | state_region     |         | State / Region | false    | false     | false  |
      | city             |         | City           | false    | false     | false  |
      | zip              |         | ZIP Code       | false    | false     | false  |
      | vat              |         | VAT Code       | false    | false     | false  |

  Scenario: Steps of the wizard
    When I go to the billing information wizard page
    And I fill in the following:
      | Organization/Group Name | Fantastically awesome API |
      | Address                 | Middle of nowhere         |
      | State / Region          | Cadiz                     |
      | City                    | Jerez                     |
      | ZIP Code                | 4242                      |
      | VAT Code                | 111111                    |
    And I select "Spain" from "Country"
    And I press "Save and continue with payment details"
    And I should be on the provider braintree edit credit card details page
    And I fill in the braintree credit card form
    And I press "Save credit card"
    Then the current domain should be admin.foo.3scale.localhost
    And I should be on the provider account page
