@javascript
Feature: Outbox messages
  In order to facilitate communication between me and my buyers
  As a provider
  I want to have an internal messaging system at my disposal

  Background:
    Given a provider "foo.3scale.localhost"
    Given a default application plan "Basic" of provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has multiple applications enabled

    Given a following buyers with applications exists:
      | name | provider        | applications        |
      | bob  | foo.3scale.localhost | BobApp              |
      | jane | foo.3scale.localhost | JaneApp, JaneAppTwo |

    Given current domain is the admin domain of provider "foo.3scale.localhost"
      And I don't care about application keys

  Scenario: Outbox Message can't be sent without subject/body
    Given I am logged in as provider "foo.3scale.localhost"
    And I am on the outbox compose page
    And a clear email queue
    And I fill in "Body" with "There is no Subject to this email"
    And I press "Send"
    Then I should see "Compose"
    And "jane@me.us" should receive no emails
