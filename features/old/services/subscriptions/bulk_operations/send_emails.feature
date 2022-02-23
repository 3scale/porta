@javascript
Feature: Mass email bulk operations
  In order to contact application owners
  As a provider
  I want to send emails to application owners in bulk

  Background:
    Given all the rolling updates features are off

    Given a provider "foo.3scale.localhost"
      And a default service of provider "foo.3scale.localhost" has name "Fancy API"
      And a service "New Service" of provider "foo.3scale.localhost"
    Given a default service plan "Basic" of service "Fancy API"
      And a service plan "Unpublished" of service "New Service"

    Given the following buyers with service subscriptions signed up to provider "foo.3scale.localhost":
      | name | plans              |
      | bob  | Basic, Unpublished |
      | jane | Basic              |
      | mike | Unpublished        |

    Given admin of account "jane" has email "jane@me.us"
      And admin of account "bob" has email "bob@me.us"

    Given current domain is the admin domain of provider "foo.3scale.localhost"
    Given I am logged in as provider "foo.3scale.localhost"

  Scenario: Emails can't be sent without body
    Given provider "foo.3scale.localhost" has "service_plans" visible
    And I am on the service contracts admin page
    And a clear email queue
    When I check select for "jane"
    And I press "Send email"
    And I fill in "Subject" with "Nothing to say"
    And I fill in "Body" with ""
    And I press "Send"
    Then I should see "Selected Service Subscriptions"
      And "jane@me.us" should not receive an email with the following subject:
      """
        Nothing to say
      """

  Scenario: Emails can't be sent without subject
    Given provider "foo.3scale.localhost" has "service_plans" visible
    And I am on the service contracts admin page
    And a clear email queue
    When I check select for "jane"
    And I press "Send email"
    And I fill in "Subject" with ""
    And I fill in "Body" with "Did I forget to add a subject?"
    And I press "Send"
    Then I should see "Selected Service Subscriptions"
      And "jane@me.us" should not receive an email with the following body:
      """
        Did I forget to add a subject?
      """

  Scenario: Send mass email to application owners
      And provider "foo.3scale.localhost" has "service_plans" visible
      And I am on the service contracts admin page
      And a clear email queue

    When I check select for "bob" and "jane"
      And I press "Send email"

    Then I should see "Send email to selected subscribers"

    When I fill in "Subject" with "Hi service subscribers!"
      And I fill in "Body" with "I just wanted to say hello!"
      And I press "Send" and I confirm dialog box within fancybox

    Then I should see "Action completed successfully"
      And "bob@me.us" should receive 2 emails with subject "Hi service subscribers!"
      And "jane@me.us" should receive an email with the following body:
      """
      I just wanted to say hello!
      """

  Scenario: Error template shows correctly
    And provider "foo.3scale.localhost" has "service_plans" visible
    And I am on the service contracts admin page
    And a clear email queue
    When I check select for "jane"
    And I press "Send email"
    And I fill in "Subject" with "Error"
    And I fill in "Body" with "This will fail"
    Given the email will fail when sent
    And I press "Send" and I confirm dialog box within colorbox
    Then I should see the bulk action failed with account "jane"
