@backend @ignore-backend
Feature: Buyer side, application extra fields
  In order to have awesome applications
  A buyer
  Has to deal with extra fields

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" has multiple applications enabled
      And an application plan "Default" of provider "foo.example.com"
      And default service of provider "foo.example.com" has name "API"
    And a buyer "bob" signed up to service "API"
    Given provider "foo.example.com" has the following fields defined for "Cinstance":
      | name         | choices | required | read_only | hidden |
      | engine       |         | true     |           |        |
      | wheels       | 1,2,3,4 | true     |           |        |
      | color        |         |          |           |        |
      | non-editable |         |          | true      |        |
      | stealth      |         |          |           | true   |

  Scenario: Hidden and not editable extra fields should not be editable
    Given I log in as "bob" on foo.example.com
    And I go to the new application page
    Then I should see the fields:
      | name        |
      | Description |
      | Engine      |
      | Wheels      |
      | Color       |
    But I should not see the fields:
      | Non-editable |
      | Stealth      |

  Scenario: Create an application with extra fields
    Given I log in as "bob" on foo.example.com
    When I go to the new application page
      And I fill in the following:
        | Name        | Skoda    |
        | Description | Roomster |
      And I select "3" from "Wheels"
      And I press "Create"
    Then I should see error "can't be blank" for extra field "engine"
      But I should not see errors for extra field "colors"

     When I fill in "Engine" with "1 Horse Power"
       And I press "Create"
     Then I should see "Application was successfully created"
       And buyer "bob" should have 1 cinstance

  Scenario: Show an application with extra fields
    Given buyer "bob" has application "Skoda" with extra fields:
      | engine | wheels | stealth | non-editable |
      | foo    | bar    | bat     | edit me      |
      And I log in as "bob" on foo.example.com
    When I go to the "Skoda" application page
    Then I should see "Non-editable"
      And I should see "Engine"
      And I should see "Wheels"
    But I should not see "Stealth"

  Scenario: Edit an application with extra fields
    Given buyer "bob" has application "Skoda" with extra fields:
      | engine | wheels | stealth | Non-editable |
      | foo    | bar    | bat     | edit me      |
      And I log in as "bob" on foo.example.com
    When I go to the "Skoda" application edit page
      And I fill in "Engine" with "turbo"
      And I select "2" from "Wheels"
      And I press "Update"
    Then I should see "Application was successfully updated."

  Scenario: Extra fields are sorted by position
    Given I log in as "bob" on foo.example.com
      And provider "foo.example.com" has the field "wheels" for "Cinstance" in the position 20
    When I go to the new application page
    Then I should see the fields in order:
      | name        |
      | Description |
      | Engine      |
      | Color       |
      | Wheels      |
    But I should not see the fields:
      | Non-editable |
      | Stealth      |

