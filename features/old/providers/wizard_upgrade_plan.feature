Feature: Wizard Billing information
  In order to provider my billing information
  As a provider
  I want a wizard to enter the required account information and credit card information

  Background:
  Given a provider "foo.example.com"
    And provider "foo.example.com" doesn't have billing address
    And current domain is the admin domain of provider "foo.example.com"
    And provider "master" has billing enabled
    And provider "master" has testing credentials for braintree
    And Braintree is stubbed to accept credit card
    And Braintree is stubbed for wizard
    And I log in as provider "foo.example.com"
  Given master provider has the following fields defined for "Account":
      | name              | choices | label          | required | read_only | hidden |
      | org_legaladdress  |         | Address        | false    | false     | false  |
      | country           |         | Country        | false    | false     | false  |
      | state_region      |         | State / Region | false    | false     | false  |
      | city              |         | City           | false    | false     | false  |
      | zip               |         | ZIP Code       | false    | false     | false  |
      | vat               |         | VAT Code       | false    | false     | false  |


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
    When I fill in the following:
      | First Name                | Pepe                    |
      | Last Name                 | Ventura                 |
      | Number                    | 4111111111111111        |
      | Cvv                       | 123                     |
      | Expiration Date (MM/YY)   | 12/22                   |
      | Company                   | comp                    |
      | Street Address            | Calle Simpecado         |
      | City                      | Sevilla                 |
      | ZIP / Postal Code         | 4242                    |
      | Phone                     | +2342342342             |
    And I select "Spain" from "Country"
    And I press "Save credit card"
   Then the current domain should be admin.foo.example.com
   And I should be on the provider account page
