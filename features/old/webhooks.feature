Feature: Webhooks

  Background:
    Given a provider "foo.3scale.localhost"
    And a buyer "bob" of provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" has all webhooks enabled
    And provider "foo.3scale.localhost" has all the templates setup

  @javascript
  Scenario: Webhooks are not fired when I log in and browse the developer portal
    Given there are no enqueued jobs
    When I log in as "bob" on foo.3scale.localhost
    Then there should be no webhooks enqueued
    When I follow "Settings"
    Then there should be no webhooks enqueued
