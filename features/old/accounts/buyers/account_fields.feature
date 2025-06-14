Feature: Buyer side, account fields
  In order to have awesome accounts
  A buyer
  Has to deal with extra fields


  Background:
    Given a provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has "multiple_applications" visible
    And a buyer "bob" signed up to provider "foo.3scale.localhost"
    Given provider "foo.3scale.localhost" has the following fields defined for accounts:
      | name            | choices | required | read_only | hidden |
      | false_field     |         |          |           |        |
      | required_field  |         | true     |           |        |
      | choices_field   | 1,2,3,4 | true     |           |        |
      | non_editable    |         |          | true      |        |
      | hidden_field    |         |          |           | true   |

  @javascript
  Scenario: Hidden and not editable extra fields should not be editable
    Given I log in as "bob" on foo.3scale.localhost
    When I go to the account edit page
    Then I should see the fields:
      | Organization/Group Name |
      | False field             |
      | Required field          |
      | Choices field           |

    But I should not see the fields:
      | hidden_fields |
      | Non editable  |
      | Hidden field  |


  Scenario: Update an account with extra fields
    Given I log in as "bob" on foo.3scale.localhost
    When I go to the account edit page
    And the form is submitted with:
      | Required field |   |
      | False field    |   |
      | Choices field  | 3 |
    Then I should see error "can't be blank" for extra field "Required field"
      But I should not see errors for extra field "False field"

     When I fill in "Required field" with "1 Horse Power"
       And I press "Update"
     Then I should see "The account information was updated"

  Scenario: Read-only extra fields are ignored on update
    Given I log in as "bob" on foo.3scale.localhost
    And provider "foo.3scale.localhost" has the field "non_editable" for accounts as editable
    Then I go to the account edit page
    And provider "foo.3scale.localhost" has the field "non_editable" for accounts as read only
    And the form is submitted with:
      | Required field | value  |
      | False field    |        |
      | Choices field  |      3 |
      | Non editable   | edited |
    Then I should see "The account information was updated"
    Then I should not see "Non editable"

  Scenario: Viewing account with extra fields
    #TODO ugly table change this
    Given buyer "bob" has extra fields:
      | false_field | required_field | choices_field | non_editable | hidden_field |
      | falses      | required       | 1             | non_edit     | hidden       |
      And I log in as "bob" on foo.3scale.localhost
    When I go to the account page
    Then I should see "False field"
      And I should see "Required field"
      And I should see "Choices field"
      And I should see "Non editable"
    But I should not see "Hidden field"

  Scenario: Extra fields are sorted by position
    Given I log in as "bob" on foo.3scale.localhost
      And provider "foo.3scale.localhost" has the field "required_field" for "Account" in the position 20
    When I go to the account edit page
    Then I should see the fields in order:
      | name                    |
      | Organization/Group Name |
      | False field             |
      | Choices field           |
      | Required field          |

  Scenario: Country field works correctly
    Given provider "foo.3scale.localhost" has the following fields defined for accounts:
      | name    |
      | country |
      And I log in as "bob" on foo.3scale.localhost
    When I go to the account edit page
      And I select "Spain" from "Country"
      And I press "Update"
    Then I should see "The account information was updated"
      And I should see "Spain" in the "country" field in the list
