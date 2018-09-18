Feature: Fields Definitions
  In order to store more data about my users
  As a provider
  I need to define and use extra fields

  Background:
  Given a provider "foo.example.com"
    And current domain is the admin domain of provider "foo.example.com"
    And I log in as provider "foo.example.com"

  Scenario: Required fields can't be deleted
    When I go to the fields definitions index page
    Then I should see "Edit"
      But I should not see "Delete"

  # TODO: Test CRUD for real, this is just making sure the page displays ok
  Scenario: Create a new field definition
    When I go to the fields definitions index page
     And I follow "Create"
    Then I should see "New Field"

  Scenario: Edit a field definition
    When I go to the fields definitions index page
    And I follow "Edit"
    Then I should see "Editing field"

  Scenario: Show all buyer fields being a provider
    Given provider "foo.example.com" has the following fields defined for "Account":
      | name             | required | read_only | hidden |
      | vat_code         | true     |           |        |
      | telephone_number |          | true      |        |
      | vat_rate         |          |           | true   |
      | car_type         | true     |           |        |
      | head_size        |          | true      |        |
      | hidden           |          |           | true   |

      And a buyer "randomdude" signed up to provider "foo.example.com"
      And buyer "randomdude" has extra fields:
      | car_type       | head_size      | hidden |
      | extra_required | user_read_only | hidden |

      And account "randomdude" has telephone number "666"
      And VAT rate of buyer "randomdude" is 9%
      And VAT code of buyer "randomdude" is 9

    When I go to the buyer account page for "randomdude"
    Then I should see the fields in order:
      | present          |
      | Vat Code         |
      | Telephone Number |
      | Vat rate         |
      | Car type         |
      | Head size        |
      | Hidden           |
