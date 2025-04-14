@javascript
Feature: Audience > Accounts > Edit

  Background:
    Given a provider is logged in
    And a buyer "Pepe"

  Scenario: Navigation
    Given they go to the provider dashboard
    When they follow "1 Account" within the audience dashboard widget
    And follow "Pepe"
    And follow "Edit"
    Then the current page is the buyer account edit page for "Pepe"

  Scenario: Editing an account
    Given they go to the buyer account edit page for "Pepe"
    When the form is submitted with:
      | Organization/Group Name | Pepito |
    Then the current page is the buyer account page for "Pepito"
    And should see the flash message "Account successfully updated"

  Scenario: Deleting an account
    Given a buyer "Deleteme"
    When they go to the buyer account edit page for "Deleteme"
    And follow "Delete"
    And confirm the dialog
    Then the current page is the buyer accounts page
    And they should see the flash message "The account was successfully deleted."
    And should see the following table:
      | Group/Org. |
      | Pepe       |

  Scenario: Provider should see all fields defined for account
    And the provider has the following fields defined for accounts:
      | Name                 | Required | Read only | Hidden | Label                |
      | vat_code             | true     |           |        | VAT Code             |
      | telephone_number     |          | true      |        | Telephone Number     |
      | vat_rate             |          |           | true   | VAT Rate             |
      | user_extra_required  | true     |           |        | User extra required  |
      | user_extra_read_only |          | true      |        | User extra read only |
      | user_extra_hidden    |          |           | true   | User extra hidden    |

    And buyer "Pepe" has extra fields:
      | user_extra_required | user_extra_read_only | user_extra_hidden |
      | extra_required      | user_read_only       | hidden            |

    And buyer "Pepe" has telephone number "666"
    And VAT rate of buyer "Pepe" is 9%
    And VAT code of buyer "Pepe" is 9

    And they go to the buyer account "Pepe" edit page

    Then they should see the fields:
      | VAT Code             |
      | Telephone Number     |
      | VAT Rate             |
      | User extra required  |
      | User extra read only |
      | User extra hidden    |

    When they press "Update Account"
    Then they should not see error in fields:
      | errors              |
      | Vat code            |
      | User extra required |

  Scenario: Edit fields with choices
    Given the provider has the following fields defined for accounts:
      | Name                 | Choices                 | Label                  | Required | Read only | Hidden |
      | country              |                         | Country                | true     |           |        |
      | field_with_choices   | hello, option1, option2 | Fields with choices    | true     |           |        |
    And the provider has the following buyers:
      | Name    | Country  |
      | Alice   | Spain    |
    And buyer "Alice" has extra fields:
      | field_with_choices |
      | option1            |

    When they go to the buyer account "Alice" edit page
    And "Spain" is the option selected in "Country"
    And "option1" is the option selected in "Fields with choices"
    And they select "United States of America" from "Country"
    And they select "option2" from "Fields with choices"
    And they press "Update Account"
    And the inverted table has the following rows within the account details card:
      | Country | United States of America |
      | Fields with choices | option2 |
