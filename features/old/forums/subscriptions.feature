# TODO: THREESCALE-8033 Remove this step as it's no longer in use.
@saas-only
Feature: Users can subscribe to forum topics
  In order for the forum to be more useful
  The users should be able to follow the topics the are interested

  Background:
    Given a published plan "Basic" of provider "Master account"
      And plan "Basic" has "Forum" enabled
    Given a provider "foo.3scale.localhost" signed up to plan "Basic"
    And all the rolling updates features are off
      And provider "foo.3scale.localhost" has "forum" enabled
      And the forum of "foo.3scale.localhost" have topics
      And a buyer "buyer" signed up to provider "foo.3scale.localhost"
      And an active user "luser" of account "buyer"
    Given provider "foo.3scale.localhost" has the following users:
     | User          | State  |
     | member_on_foo | active |
    When the current domain is foo.3scale.localhost

  @javascript
  Scenario: User cannot see Forum
    Given I am logged in as "buyer"
    Then I should not see forum

  @emails
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


  Scenario: User manages can't manage topics because can't see Forum
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
    Then I should see "Page not found"
