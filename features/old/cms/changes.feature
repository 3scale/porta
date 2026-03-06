@javascript
Feature: CMS Changes
  As a provider
  I want to manage all not published CMS changes on one place

  Background:
    Given a provider is logged in

  Scenario: Changes
    Given a dev portal page "My Page" has unpublished changes
    And a dev portal partial "My partial" has unpublished changes
    And a dev portal layout "My Layout" has unpublished changes
    And I go to the CMS changes
    Then the table should contain the following:
      | Type    | Name       |
      | Page    | My Page    |
      | Partial | My partial |
      | Layout  | My Layout  |

  Scenario: Revert page
    Given a dev portal page "My Page" has unpublished changes
    When I go to the CMS changes
    And the table should contain the following:
      | Type | Name |
      | Page | My Page |
    And I follow "Revert"
    Then they should see a toast alert with text "Template reverted"
    And the table should contain the following:
      | Type | Name |
