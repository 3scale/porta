# TODO: THREESCALE-8033 Remove this step as it's no longer in use.
@saas-only
Feature: Users can subscribe to forum topics
  In order for the forum to be more useful
  The users should be able to follow the topics the are interested

  Background:
    Given a published plan "Basic" of provider "Master account"
      And plan "Basic" has "Forum" enabled
    Given a provider "foo.3scale.localhost" signed up to plan "Basic"
    And all the rolling updates features are on
      And provider "foo.3scale.localhost" has "forum" enabled
      And the forum of "foo.3scale.localhost" have topics
      And a buyer "buyer" signed up to provider "foo.3scale.localhost"
      And an active user "luser" of account "buyer"
    Given provider "foo.3scale.localhost" has the following users:
     | User          | State  |
     | member_on_foo | active |
    When the current domain is foo.3scale.localhost

    @javascript
  Scenario: Active user can subscribe to topics
    Given I am logged in as "buyer"
    When I navigate to a topic in the forum of "foo.3scale.localhost"
    Then I should see the link to subscribe to topic
    When I follow "Subscribe to thread"
    Then I should see that I am subscribed to the topic
    Then I should see the link to unsubscribe to topic


  Scenario: Email unverified user can not subscribe to topics
    Given I am logged in as "buyer"
      And user "buyer" is email unverified
    When I navigate to a topic in the forum of "foo.3scale.localhost"
    Then I should see the notice to validate my email

  Scenario: User subscribe to topics
    Given I am logged in as "buyer"
    When I navigate to a topic in the forum of "foo.3scale.localhost"
    When user "buyer" subscribe to the topic in the forum of "foo.3scale.localhost"

    When I navigate to a topic in the forum of "foo.3scale.localhost"
    Then I should see that I am subscribed to the topic
      And I should see the link to unsubscribe to topic
      And I unsubscribe the topic
      Then I should see the link to subscribe to topic

  @emails @wip
  Scenario: Active user subscribed to topic receives email on new posts in topic
    Given user "buyer" is subscribed to the topic in the forum of "foo.3scale.localhost"
    When the user "member_on_foo" post in the topic in the forum of "foo.3scale.localhost"
    Then the user "buyer" should receive an email notifying of the new post

  Scenario: Active user subscribed to topic does not receive email when he creates a new post in topic
    Given user "foo.3scale.localhost" is subscribed to the topic in the forum of "foo.3scale.localhost"
    When the user "foo.3scale.localhost" post in the topic in the forum of "foo.3scale.localhost"
    Then the user "foo.3scale.localhost" should not receive an email notifying of the new post

  Scenario: Email unverified user subscribed to topic does not receives email on new posts in topic
    Given user "foo.3scale.localhost" is subscribed to the topic in the forum of "foo.3scale.localhost"
      And user "foo.3scale.localhost" is email unverified
    When the user "member_on_foo" post in the topic in the forum of "foo.3scale.localhost"
    Then the user "foo.3scale.localhost" should not receive an email notifying of the new post


  Scenario: User manages its subscriptions to topics
    Given the forum of "foo.3scale.localhost" has the following topics:
      | Topic                    |
      | subscribed topic         |
      | another subscribed topic |
      | no subscribed to topic   |
    And the user "buyer" is subscribed to the topics:
      | topic                    |
      | subscribed topic         |
      | another subscribed topic |
    Given I am logged in as "buyer"
    When I go to the forum page
      And I follow the link to my subscriptions to topics

    Then I should see the topics I follow:
      | topic                    |
      | subscribed topic         |
      | another subscribed topic |
    But I should not see the topics I do not follow:
      | topic                    |
      | no subscribed to topic   |

  Rule: Forum disabled
    Background:
      Given I have rolling updates "forum" disabled
      And provider "foo.3scale.localhost" has "forum" enabled

    Scenario: Buyer cannot access Forum
      When I should not see forum
