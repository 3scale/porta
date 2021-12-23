@javascript
Feature: Mass email bulk operations
  In order to contact application owners
  As a provider
  I want to send emails to application owners in bulk

  Background:
    Given all the rolling updates features are off
    Given a provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has multiple applications enabled

    Given these buyers signed up to provider "foo.3scale.localhost"
      | bob  |
      | jane |

    Given admin of account "jane" has email "jane@jane.com"
      And admin of account "bob" has email "bob@bob.com"
      And I don't care about application keys

    Given current domain is the admin domain of provider "foo.3scale.localhost"
      And I am logged in as provider "foo.3scale.localhost"

  Scenario: Emails can be sent without body
    And I am on the accounts admin page
    And a clear email queue
    When I check select for "jane"
    And I press "Send email"
    And I fill in "Subject" with "Nothing to say"
    And I press "Send" and I confirm dialog box within colorbox
    Then I should see "Action completed successfully"
    And "jane@jane.com" should receive an email with the following body:
    """
    """

  Scenario: Emails can be sent without subject
    And I am on the accounts admin page
    And a clear email queue
    When I check select for "jane"
    And I press "Send email"
    And I fill in "Body" with "Did I forget to add a subject?"
    And I press "Send" and I confirm dialog box within colorbox
    Then I should see "Action completed successfully"
    And "jane@jane.com" should receive an email with the following body:
    """
    Did I forget to add a subject?
    """

  Scenario: Send mass email to application owners
      And I am on the accounts admin page
      And a clear email queue

    When I check select for "bob" and "jane"
      And I press "Send email"

    Then I should see "Send email to selected accounts"

    When I fill in "Subject" with "Hi account!"
      And I fill in "Body" with "I just wanted to say hello!"
      And I press "Send" and I confirm dialog box within colorbox

    Then I should see "Action completed successfully"
      And "jane@jane.com" should receive 1 email with subject "Hi account!"
      And "bob@bob.com" should receive an email with the following body:
      """
      I just wanted to say hello!
      """

