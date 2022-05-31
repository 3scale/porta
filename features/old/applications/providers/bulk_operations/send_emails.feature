@javascript
Feature: Mass email bulk operations
  In order to contact application owners
  As a provider
  I want to send emails to application owners in bulk

  Background:
    Given all the rolling updates features are off
    Given a provider "foo.3scale.localhost"
    Given a default application plan "Basic" of provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has multiple applications enabled

    Given a following buyers with applications exists:
      | name | provider        | applications        |
      | bob  | foo.3scale.localhost | BobApp              |
      | jane | foo.3scale.localhost | JaneApp, JaneAppTwo |
      | mike | foo.3scale.localhost | MikeApp             |

    Given admin of account "jane" has email "jane@me.us"
      And admin of account "bob" has email "bob@me.us"

    Given current domain is the admin domain of provider "foo.3scale.localhost"
      And I don't care about application keys

  Scenario: Emails can't be sent without body
    Given I am logged in as provider "foo.3scale.localhost"
    And I am on the applications admin page
    And a clear email queue
    When I check select for "BobApp"
    And I press "Send email"
    And I fill in "Subject" with "Nothing to say"
    And I press "Send"
    Then I should see "Selected Applications"
    And "jane@me.us" should receive no emails

  Scenario: Emails can't be sent without subject
    Given I am logged in as provider "foo.3scale.localhost"
    And I am on the applications admin page
    And a clear email queue
    When I check select for "BobApp"
    And I press "Send email"
    And I fill in "Body" with "There is no Subject to this email"
    And I press "Send"
    Then I should see "Selected Applications"
    And "jane@me.us" should receive no emails
    
  Scenario: Send mass email to application owners
    Given I am logged in as provider "foo.3scale.localhost"
      And I am on the applications admin page
      And a clear email queue

    When I check select for "BobApp", "JaneApp" and "JaneAppTwo"
      And I press "Send email"

    Then I should see "Send email to owners of selected applications"

    When I fill in "Subject" with "Hi application owners!"
      And I fill in "Body" with "I just wanted to say hello!"
      And I press "Send" and I confirm dialog box within colorbox

    Then I should see "Action completed successfully"
      And "jane@me.us" should receive 2 emails with subject "Hi application owners!"
      And "bob@me.us" should receive an email with the following body:
      """
      I just wanted to say hello!
      """

  Scenario: Error template shows correctly
    Given I am logged in as provider "foo.3scale.localhost"
    And I am on the applications admin page
    And a clear email queue
    When I check select for "JaneApp"
    And I press "Send email"
    And I fill in "Subject" with "Error"
    And I fill in "Body" with "This will fail"
    Given the email will fail when sent
    And I press "Send" and I confirm dialog box within colorbox
    Then I should see the bulk action failed with account "jane"
    