@fakeweb
Feature: Buyer side, user extra fields
  In order to have awesome users
  A buyer
  Has to deal with extra fields


  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" has multiple applications enabled
    And a buyer "bob" signed up to provider "foo.example.com"
    Given provider "foo.example.com" has the following fields defined for "User":
      | name            | choices | required | read_only | hidden |
      | false_field     |         |          |           |        |
      | required_field  |         | true     |           |        |
      | choices_field   | 1,2,3,4 | true     |           |        |
      | non_editable    |         |          | true      |        |
      | hidden_field    |         |          |           | true   |


  Scenario: Hidden and not editable extra fields should not be editable
    Given I log in as "bob" on foo.example.com
    When I go to the user edit page for "bob"
    Then I should see the fields:
      | name           |
      | Username       |
      | Email          |
      | False field    |
      | Required field |
      | Choices field  |
    But I should not see the fields:
      | hidden fields |
      | Non editable  |
      | Hidden field  |


  Scenario: Update a user with extra fields
    Given I log in as "bob" on foo.example.com
    When I go to the user edit page for "bob"
      And I leave "Required field" blank
      And I leave "False field" blank
      And I select "3" from "Choices field"
      And I press "Update User"
    Then I should see error "can't be blank" for extra field "Required field"
      But I should not see errors for extra field "False field"

     When I fill in "Required field" with "1 Horse Power"
       And I select "3" from "Choices field"
       And I press "Update User"
     Then I should see "User was successfully updated."

  # Scenario: Viewing user with extra fields
