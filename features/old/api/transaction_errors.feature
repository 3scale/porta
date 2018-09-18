@fakeweb
Feature: Transaction Errors
  In order to know if my integration with 3scale is done correctly
  As a provider
  I want to see any errors that happen during transaction processing

  Background:
    Given a provider "foo.example.com"

  Scenario: No errors
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"

    Given provider "foo.example.com" has no transaction errors
    When I go to the transaction errors page
    Then I should see "Hooray! No integration errors reported for this service."

  Scenario: Some errors
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"

    Given provider "foo.example.com" has the following transaction errors:
      | Timestamp           | Code                  | Message                                 |
      | 2010-09-27 12:21:00 | application_not_found | application with is="boo" was not found |
      | 2010-09-27 12:18:00 | metric_invalid        | metric "monkeys" is invalid             |

    When I go to the transaction errors page
    Then I should see the following transactions errors:
      | Timestamp           | Code                  | Message                                 |
      | 2010-09-27 12:21:00 | application_not_found | application with is="boo" was not found |
      | 2010-09-27 12:18:00 | metric_invalid        | metric "monkeys" is invalid             |


  # Marked as WIP because of: http://code.google.com/p/selenium/issues/detail?id=1438
  @javascript @wip
  Scenario: Purge errors
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"

    Given provider "foo.example.com" has the following transaction errors:
      | Timestamp           | Code                  | Message                     |
      | 2010-09-27 12:25:00 | metric_invalid        | metric "apes" is invalid    |
      | 2010-09-27 12:22:00 | metric_invalid        | metric "monkeys" is invalid |
    And the backend will delete transaction errors of provider "foo.example.com"
    When I go to the transaction errors page
    And I press "Purge"
    Then I should not see any transaction errors

  Scenario: Transaction errors are only available on the v2 backend
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"

    Given provider "foo.example.com" uses backend v1 in his default service
    When I go to the provider dashboard
    And I follow "API" within the main menu
    Then I should not see link "Errors"
