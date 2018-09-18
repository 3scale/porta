@saas-only
Feature: Users can subscribe to forum topics
  In order for the forum to be more useful
  The users should be able to follow the topics the are interested

  Background:
    Given a published plan "Basic" of provider "Master account"
      And plan "Basic" has "Forum" enabled
    Given a provider "foo.example.com" signed up to plan "Basic"
    And all the rolling updates features are off
      And provider "foo.example.com" has "forum" enabled
      And the forum of "foo.example.com" have topics
      And a buyer "buyer" signed up to provider "foo.example.com"
      And an active user "luser" of account "buyer"
    Given provider "foo.example.com" has the following users:
     | User          | State  |
     | member_on_foo | active |
    When the current domain is foo.example.com

    @javascript
  Scenario: Active user can subscribe to topics
    Given I am logged in as "buyer"
    When I navigate to a topic in the forum of "foo.example.com"
    Then I should see the link to subscribe to topic
    When I follow "Subscribe to thread"
    Then I should see that I am subscribed to the topic
    Then I should see the link to unsubscribe to topic


  Scenario: Email unverified user can not subscribe to topics
    Given I am logged in as "buyer"
      And user "buyer" is email unverified
    When I navigate to a topic in the forum of "foo.example.com"
    Then I should see the notice to validate my email

  Scenario: User subscribe to topics
    Given I am logged in as "buyer"
    When I navigate to a topic in the forum of "foo.example.com"
    When user "buyer" subscribe to the topic in the forum of "foo.example.com"

    When I navigate to a topic in the forum of "foo.example.com"
    Then I should see that I am subscribed to the topic
      And I should see the link to unsubscribe to topic
      And I unsubscribe the topic
      Then I should see the link to subscribe to topic

  @emails
  Scenario: Active user subscribed to topic receives email on new posts in topic
    Given user "buyer" is subscribed to the topic in the forum of "foo.example.com"
    When the user "member_on_foo" post in the topic in the forum of "foo.example.com"
    Then the user "buyer" should receive an email notifying of the new post


  Scenario: Active user subscribed to topic does not receive email when he creates a new post in topic
    Given user "foo.example.com" is subscribed to the topic in the forum of "foo.example.com"
    When the user "foo.example.com" post in the topic in the forum of "foo.example.com"
    Then the user "foo.example.com" should not receive an email notifying of the new post


  Scenario: Email unverified user subscribed to topic does not receives email on new posts in topic
    Given user "foo.example.com" is subscribed to the topic in the forum of "foo.example.com"
      And user "foo.example.com" is email unverified
    When the user "member_on_foo" post in the topic in the forum of "foo.example.com"
    Then the user "foo.example.com" should not receive an email notifying of the new post


  Scenario: User manages its subscriptions to topics
    Given the forum of "foo.example.com" has the following topics:
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
