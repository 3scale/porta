@ignore-backend
Feature: Applications details
  In order to have a cool interface of applications
  As a provider
  I want to see all the extra fields for my buyer's application

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" uses backend v2 in his default service
      And provider "foo.example.com" has multiple applications enabled
      And a default application plan "Basic" of provider "foo.example.com"
      And a buyer "bob" signed up to provider "foo.example.com"

      And current domain is the admin domain of provider "foo.example.com"
      And I am logged in as provider "foo.example.com"
      And I don't care about application keys

  Scenario: No special settings
    When buyer "bob" has application "OKWidget"
     And I navigate to the application "OKWidget" of the partner "bob"
    Then I should see the app menu
    And I should see "Add Random key"

  Scenario: Editing hidden fields
    Given provider "foo.example.com" has the following fields defined for "Cinstance":
      | name            | choices     | required | read_only | hidden |
      | le_hidden_field |             |          |           | true   |
      | avec_choices    | true, false |          |           |        |

    And buyer "bob" has application "OKWidget"

    When I navigate to the application "OKWidget" of the partner "bob"
      And I follow "Edit"
    Then I should be on the provider side "OKWidget" edit application page
      And I should see "Le hidden field"
    When I fill in "Le hidden field" with "secret souce"
      And I press "Update Application"
    Then I should be on the provider side "OKWidget" application page
      And I should see "secret souce"

  @random-fail
  Scenario: I should see all defined fields for an application
    Given provider "foo.example.com" has the following fields defined for "Cinstance":
      | name                 | required | read_only | hidden |
      | user_extra_required  | true     |           |        |
      | user_extra_read_only |          | true      |        |
      | user_extra_hidden    |          |           | true   |

    When buyer "bob" has application "OKWidget" with extra fields:
    | user_extra_required | user_extra_read_only | user_extra_hidden |
    | extra_required      | user_read_only       | hidden            |

    And I navigate to the application "OKWidget" of the partner "bob"
    Then I should see the fields in order:
    | name                 |
    | Description          |
    | User extra required  |
    | User extra read only |
    | User extra hidden    |
