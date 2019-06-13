Feature: Provider Payment Details
  In order to pay to our master

  Background:
    Given a provider "foo.example.com"
    And provider "master" manages payments with "braintree_blue"
    And provider "master" has testing credentials for braintree

  Scenario: Upload logo
    Given master provider has the following fields defined for "Account":
      | name              | choices | label          | required | read_only | hidden |
      | org_legaladdress  |         | Address        | false    | false     | false  |
      | country           |         | Country        | false    | false     | false  |
      | state_region      |         | State / Region | false    | false     | false  |
      | city              |         | City           | false    | false     | false  |
      | zip               |         | ZIP Code       | false    | false     | false  |
      | vat               |         | VAT Code       | false    | false     | false  |

    Given current domain is the admin domain of provider "foo.example.com"
      And I log in as provider "foo.example.com"
    When I follow "Account"
      And I follow "Billing"
      And I follow "Payment Details"
    Then I should be on the provider braintree credit card details page
      And I follow "Add Payment Details"

    Then I should be on the provider edit account page
    And I should see "Edit Account Details"
    And fill in "Organization/Group Name" with "coconut"
    And fill in "State / Region" with "foo"
    And fill in "City" with "foo"
    And fill in "ZIP Code" with "foo"
    And fill in "VAT Code" with "foo"
    And I select "Spain" from "Country"
    And I press "Save and continue with payment details"
    Then I should see "Payment Details"
