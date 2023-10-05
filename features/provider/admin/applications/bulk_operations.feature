@javascript
Feature: Provider applications bulk operations

  Background:
    Given a provider is logged in
    And default service of the provider has name "Default API"
    And a default published application plan "Free" of service "Default API"
    And a published application plan "Premium" of service "Default API"
    And an approved buyer "Bob Buyer" signed up to the provider
    And the buyer has the following applications:
      | Name  |
      | App 1 |
      | App 2 |
    And the owner of application "App 1" has email "buyer@example.com"
    And a service "Secondary API" of the provider
    And a default published application plan "Secondary Plan" of service "Secondary API"
    And the buyer has application "Secondary App" with plan "Secondary Plan"
    And they go to the applications admin page

  Scenario: Available bulk operations
    When item "App 1" is selected
    Then the following bulk operations are available:
      | Send email              |
      | Change application plan |
      | Change state            |

  Scenario: Bulk operations card shows when an items are selected
    When item "App 1" is selected
    And item "App 2" is selected
    Then the bulk operations are visible
    And should see "You have selected 2 applications and you can make following operations with them:"
    But item "App 1" is unselected
    And item "App 2" is unselected
    Then the bulk operations are not visible

  Scenario: Select all items in the table
    When they select all items in the table
    Then the bulk operations are visible
    When they unselect all items in the table
    Then the bulk operations are not visible

  Scenario: Send an email without subject
    When item "App 1" is selected
    And press "Send email"
    And fill in "Subject" with ""
    And fill in "Body" with "This is the body"
    And press "Send"
    Then "buyer@example.com" should receive no emails

  Scenario: Send an email without body
    When item "App 1" is selected
    And press "Send email"
    And fill in "Subject" with "This is a subject"
    And fill in "Body" with ""
    And press "Send"
    Then "buyer@example.com" should receive no emails

  Scenario: Send email in bulk
    Given "buyer@example.com" should receive no emails
    When item "App 1" is selected
    And item "App 2" is selected
    And press "Send email"
    And fill in "Subject" with "This is the subject"
    And fill in "Body" with "This is the body"
    And press "Send" and I confirm dialog box
    Then I should see "Successfully sent 2 emails."
    Then "buyer@example.com" should receive 2 email

  Scenario: Change application plan in bulk
    Given the table should contain the following:
      | Name          | Service       | Plan           |
      | App 1         | Default API   | Free           |
      | App 2         | Default API   | Free           |
      | Secondary App | Secondary API | Secondary Plan |
    And item "App 1" is selected
    When item "App 2" is selected
    And press "Change application plan"
    And select "Premium" from "Plan"
    And press "Change plan" and I confirm dialog box
    Then should see "Successfully changed the plan of 2 applications"
    And the table should contain the following:
      | Name          | Service       | Plan           |
      | App 1         | Default API   | Premium        |
      | App 2         | Default API   | Premium        |
      | Secondary App | Secondary API | Secondary Plan |

  Scenario: Can't change the plan of applications from different services
    Given item "App 1" is selected
    And item "Secondary App" is selected
    And press "Change application plan"
    Then should not see "Change plan" within the modal
    And should see "You have selected applications from different services"

  Scenario: Change state in bulk
    Given the table should contain the following:
      | Name          | State | Service       |
      | App 1         | live  | Default API   |
      | App 2         | live  | Default API   |
      | Secondary App | live  | Secondary API |
    When item "App 1" is selected
    And item "Secondary App" is selected
    And press "Change state"
    And select "Suspend" from "Action"
    And press "Change state" and I confirm dialog box within the modal
    Then should see "Successfully changed the state of 2 applications"
    And the table should contain the following:
      | Name          | State     | Service       |
      | App 1         | suspended | Default API   |
      | App 2         | live      | Default API   |
      | Secondary App | suspended | Secondary API |

  Scenario: Sending email throws an error
    Given the email will fail when sent
    When item "App 1" is selected
    And press "Send email"
    And fill in "Subject" with "Error"
    And fill in "Body" with "This will fail"
    And press "Send" and I confirm dialog box
    Then the bulk operation has failed for "Bob Buyer"
    And "buyer@example.com" should receive no emails

  Scenario: Changing state throws an error
    Given the application will return an error when suspended
    When item "App 1" is selected
    And press "Change state"
    When select "Suspend" from "Action"
    And press "Change state" and I confirm dialog box within the modal
    Then the bulk operation has failed for "App 1"
    And the table should contain the following:
      | Name          | State | Service       |
      | App 1         | live  | Default API   |
      | App 2         | live  | Default API   |
      | Secondary App | live  | Secondary API |

  Scenario: Changing app plan throws an error
    Given the application will return an error when changing its plan
    When item "App 1" is selected
    And press "Change application plan"
    When select "Premium" from "Plan"
    And press "Change plan" and I confirm dialog box
    Then the bulk operation has failed for "App 1"
    And the table should contain the following:
      | Name          | Service       | Plan           |
      | App 1         | Default API   | Free           |
      | App 2         | Default API   | Free           |
      | Secondary App | Secondary API | Secondary Plan |
