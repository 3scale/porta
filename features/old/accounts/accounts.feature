Feature: Account management
  In order to keep the information about my company or group up to date
  As a registered user
  I want to see and change my account details

  Background:
    Given a provider "foo.3scale.localhost"
    And the default product of the provider has name "My API"

  @javascript
  Scenario: Edit and show account details
    Given the admin of account "foo.3scale.localhost" has email "admin@foo.3scale.localhost"
    Given master provider has the following fields defined for accounts:
    | name              | choices | label   | required | read_only | hidden |
    | org_legaladdress  |         | Address | false    | false     | false  |
    | country           |         | Country | false    | false     | false  |

    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "foo.3scale.localhost"
     And I go to the provider edit account page
    Then I should see "Edit Account Details"

    When I fill in the following:
       | Organization/Group Name | Fantastically awesome API |
       | Address                 | Middle of nowhere         |

     And I select "United States of America" from "Country"
     And I select "Santiago" from "Time Zone"
     And I press "Update Account"

    Then I should see "The account information was updated"
      And I should see the account details:
        | Organization/Group Name | Fantastically awesome API |
        | Address                 | Middle of nowhere         |
        | Country                 | United States of America  |
        | Time Zone               | Santiago                  |
      And provider "Fantastically awesome API" time zone should be "Santiago"

  @security @javascript
  Scenario: Non-admins cannot edit account details
    Given an user "bob" of account "foo.3scale.localhost"
    And the user "bob" is activated
    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "bob"
    And I go to the provider account page
    Then I should see "Access denied"

  @javascript
  Scenario: Providers see their provider key on the account details page
    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "foo.3scale.localhost"
    And I go to the provider account page
    Then I should see "API Key"
    Then I should see the provider key of provider "foo.3scale.localhost"

  Scenario: Buyers don't see their keys on the account details page
    Given the following application plan:
      | Product | Name    |
      | My API  | Default |
    And a buyer "bob" signed up to application plan "Default"

    When I log in as "bob" on foo.3scale.localhost
    And I follow "Settings"
    Then I should not see "API Key"

  @javascript
  Scenario: Edit personal details with invalid data
    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "foo.3scale.localhost"
    And I navigate to the Account Settings
    And I go to the provider personal details page
    When I fill in "Email" with "invalid"
     And I fill in "Current password" with "superSecret1234#"
    And I press "Update Details"
    Then I should see "should look like an email address"

  @regression-test @javascript
  Scenario: Edit account information even with advanced CMS enabled
    Given current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "foo.3scale.localhost"
     And I go to the provider edit account page
    Then I should see "Edit Account Details"
