@javascript
Feature: Mass email bulk operations
  In order to contact application owners
  As a provider
  I want to send emails to application owners in bulk

  Background:
    Given all the rolling updates features are off

    Given a provider "foo.example.com"
      And a default service of provider "foo.example.com" has name "Fancy API"
      And a service "New Service" of provider "foo.example.com"
    Given a default service plan "Basic" of service "Fancy API"
      And a service plan "Unpublished" of service "New Service"

    Given the following buyers with service subscriptions signed up to provider "foo.example.com":
      | name | plans              |
      | bob  | Basic, Unpublished |
      | jane | Basic              |
      | mike | Unpublished        |

    Given admin of account "jane" has email "jane@me.us"
      And admin of account "bob" has email "bob@me.us"

    Given current domain is the admin domain of provider "foo.example.com"
    Given I am logged in as provider "foo.example.com"

  Scenario: Send mass email to application owners
      And provider "foo.example.com" has "service_plans" visible
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
