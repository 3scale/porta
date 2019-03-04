Feature: Account management
  In order to keep the information about my company or group up to date
  As a registered user
  I want to see and change my account details

  Background:
    Given a provider "foo.example.com"

  Scenario: Edit and show account details
    Given the admin of account "foo.example.com" has email "admin@foo.example.com"
    Given master provider has the following fields defined for "Account":
    | name              | choices | label   | required | read_only | hidden |
    | org_legaladdress  |         | Address | false    | false     | false  |
    | country           |         | Country | false    | false     | false  |

    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"
     And I go to the provider edit account page
    Then I should see "Edit Account Details"

    When I fill in the following:
       | Organization/Group Name | Fantastically awesome API |
       | Address                 | Middle of nowhere         |

     And I select "United States of America" from "Country"
     And I select "Santiago" from "Time Zone"
     And I press "Update Account"

    Then I should see "The account information was updated."
      And I should see the account details:
        | Organization/Group Name | Fantastically awesome API |
        | Address                 | Middle of nowhere         |
        | Country                 | United States of America  |
        | Time Zone               | Santiago                  |
      And provider "Fantastically awesome API" time zone should be "Santiago"

  @security @wip
  Scenario: Non-admins cannot edit account details
    Given an user "bob" of account "foo.example.com"
    And user "bob" activates himself
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "bob"
    And I follow "Account"
    # FIXME: as the Edit button now resides elsewhere, this does not assert anything
    Then I should not see link "Edit" within "#account_details"

  @javascript
  Scenario: Providers see their provider key on the account details page
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"
    And I follow "Account"
    Then I should see "API Key"
    Then I should see the provider key of provider "foo.example.com"

  Scenario: Buyers don't see their keys on the account details page
    Given an application plan "Default" of provider "foo.example.com"
    And a buyer "bob" signed up to application plan "Default"

    When I log in as "bob" on foo.example.com
    And I follow "Settings"
    Then I should not see "API Key"

  @wip
  Scenario: For admins the account overview is a page to change account details
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"
      And I follow "Account"
    Then I should see the page to change account details

  @wip
  Scenario: Buyer Admins can edit Customers Type on account
    Given provider "foo.example.com" has the following buyers with states:
        | buyer | state    |
        | buyer | approved |
    When I log in as "buyer" on foo.example.com
      And I follow "Settings"
    Then I should be able to edit the value of the customers type field

    When I change the value of the customers type field to "Consumers"
      And I fill in the obligatory fields for accounts
      And I press the button to update account
    Then I should see the page to change account details
      And I should see the value of the customers type field is "Consumers"

  @wip
  Scenario: Provider Admins cannot edit Profiles fields on account
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"
      And I follow "Account"
    Then I should not be able to edit the value of the customers type field

  @javascript
  Scenario: Edit personal details with invalid data
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"
    And I follow "Account Settings"
    And I follow "Personal Details"
    When I fill in "Email" with ""
     And I fill in "Current password" with "supersecret"
    And I press "Update Details"
    Then I should see "should look like an email address"

  @regression-test
  Scenario: Edit account information even with advanced CMS enabled
    When provider "foo.example.com" has Browser CMS activated
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"
     And I go to the provider edit account page
    Then I should see "Edit Account Details"

  Scenario: Provider should see all fields defined for account
    And provider "foo.example.com" has multiple applications enabled
      And provider "foo.example.com" has the following fields defined for "Account":
      | name                 | required | read_only | hidden | label                |
      | vat_code             | true     |           |        | VAT Code             |
      | telephone_number     |          | true      |        | Telephone Number     |
      | vat_rate             |          |           | true   | VAT Rate             |
      | user_extra_required  | true     |           |        | User extra required  |
      | user_extra_read_only |          | true      |        | User extra read only |
      | user_extra_hidden    |          |           | true   | User extra hidden    |

      And a buyer "randomdude" signed up to provider "foo.example.com"
      And buyer "randomdude" has extra fields:
      | user_extra_required | user_extra_read_only | user_extra_hidden |
      | extra_required      | user_read_only       | hidden            |

      And account "randomdude" has telephone number "666"
      And VAT rate of buyer "randomdude" is 9%
      And VAT code of buyer "randomdude" is 9

      And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"
      And I go to the buyer account "randomdude" edit page

    Then I should see the fields:
      | present              |
      | VAT Code             |
      | Telephone Number     |
      | VAT Rate             |
      | User extra required  |
      | User extra read only |
      | User extra hidden    |

    When I press "Update Account"
    Then I should not see error in fields:
      | errors              |
      | Vat code            |
      | User extra required |
