@javascript
Feature: Service subscriptions bulk operations

  Background:
    Given a provider is logged in
    And a service "Fancy API"
    And a default service plan "Fancy Plan A" of service "Fancy API"
    And a service plan "Fancy Plan B" of service "Fancy API"
    And a service "Another API"
    And a default service plan "Another Plan" of service "Another API"
    And the following buyers with service subscriptions signed up to the provider:
      | name  | plans                      |
      | Alice | Fancy Plan A, Another Plan |
      | Bob   | Fancy Plan A               |
      | Jane  | Another Plan               |
    And admin of account "Jane" has email "jane@example.com"
    And admin of account "Bob" has email "bob@example.com"
    And they go to the service contracts admin page

  Scenario: Available bulk operations
    When item "Alice" is selected
    Then the following bulk operations are available:
      | Send email          |
      | Change service plan |
      | Change state        |

  Scenario: Bulk operations card shows when an items are selected
    When item "Alice" is selected
    And item "Bob" is selected
    Then the bulk operations are visible
    And should see "You have selected 2 service subscriptions and you can make following operations with them:"
    But item "Alice" is unselected
    And item "Bob" is unselected
    Then the bulk operations are not visible

  Scenario: Select all items in the table
    When they select all items in the table
    Then the bulk operations are visible
    When they unselect all items in the table
    Then the bulk operations are not visible

  Scenario: Send an email without subject
    When item "Jane" is selected
    And press "Send email"
    And fill in "Subject" with ""
    And fill in "Body" with "This is the body"
    And press "Send"
    Then "jane@example.com" should receive no emails

  Scenario: Send an email without body
    When item "Jane" is selected
    And press "Send email"
    And fill in "Subject" with "This is a subject"
    And fill in "Body" with ""
    And press "Send"
    Then "jane@example.com" should receive no emails

  Scenario: Send email in bulk
    Given "jane@example.com" should receive no emails
    And "bob@example.com" should receive no emails
    When item "Jane" is selected
    And item "Bob" is selected
    And press "Send email"
    And fill in "Subject" with "This is the subject"
    And fill in "Body" with "This is the body"
    And press "Send" and I confirm dialog box
    Then I should see "Successfully sent 2 emails."
    Then "jane@example.com" should receive 1 email
    Then "bob@example.com" should receive 1 email

  Scenario: Change service plan in bulk
    Given the table should contain the following:
      | Account | Service     | Plan         |
      | Alice   | Fancy API   | Fancy Plan A |
      | Alice   | Another API | Another Plan |
      | Bob     | Fancy API   | Fancy Plan A |
      | Jane    | Another API | Another Plan |
    When item "Alice" is selected
    And item "Bob" is selected
    And press "Change service plan"
    And select "Fancy Plan B" from "Plan"
    And press "Change plan" and I confirm dialog box
    Then should see "Successfully changed the plan of 2 subscriptions"
    And the table should contain the following:
      | Account | Service     | Plan         |
      | Alice   | Fancy API   | Fancy Plan B |
      | Alice   | Another API | Another Plan |
      | Bob     | Fancy API   | Fancy Plan B |
      | Jane    | Another API | Another Plan |

  Scenario: Can't change the plan of subscriptions from different services
    When item "Jane" is selected
    And item "Bob" is selected
    And press "Change service plan"
    Then should not see "Change plan" within the modal
    And should see "You have selected subscriptions to plans from different services"

  Scenario: Change state in bulk
    Given the table should contain the following:
      | Account | Service     | State |
      | Bob     | Fancy API   | live  |
      | Jane    | Another API | live  |
      | Alice   | Fancy API   | live  |
      | Alice   | Another API | live  |
    When item "Bob" is selected
    And item "Jane" is selected
    And press "Change state"
    And select "Suspend" from "Action"
    And press "Change state" and I confirm dialog box within the modal
    Then should see "Successfully changed the state of 2 subscriptions"
    And the table should contain the following:
      | Account | Service     | State     |
      | Bob     | Fancy API   | suspended |
      | Jane    | Another API | suspended |
      | Alice   | Fancy API   | live      |
      | Alice   | Another API | live      |

  Scenario: Sending email throws an error
    Given the email will fail when sent
    When item "Jane" is selected
    And press "Send email"
    And fill in "Subject" with "Error"
    And fill in "Body" with "This will fail"
    And press "Send" and I confirm dialog box
    Then the bulk operation has failed for "Jane"
    And "jane@example.com" should receive no emails

  Scenario: Changing state throws an error
    Given the subscription will return an error when suspended
    When item "Jane" is selected
    And press "Change state"
    When select "Suspend" from "Action"
    And press "Change state" and I confirm dialog box within the modal
    Then the bulk operation has failed for "Subscription of Jane to service Another API"
    And the table should contain the following:
      | Account | Service     | State |
      | Bob     | Fancy API   | live  |
      | Jane    | Another API | live  |
      | Alice   | Fancy API   | live  |
      | Alice   | Another API | live  |

  Scenario: Changing service plan throws an error
    Given the subscription will return an error when changing its plan
    When item "Alice" is selected
    And press "Change service plan"
    And select "Fancy Plan B" from "Plan"
    And press "Change plan" and I confirm dialog box
    Then the bulk operation has failed for "Subscription of Alice to service Fancy API"
    And the table should contain the following:
      | Account | Service     | Plan         |
      | Alice   | Fancy API   | Fancy Plan A |
      | Alice   | Another API | Another Plan |
      | Bob     | Fancy API   | Fancy Plan A |
      | Jane    | Another API | Another Plan |
