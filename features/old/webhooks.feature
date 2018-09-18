Feature: Webhooks

  Background:
    Given a provider "foo.example.com"
    And a buyer "bob" of provider "foo.example.com"
    And provider "foo.example.com" has all webhooks enabled
    And provider "foo.example.com" has all the templates setup

  @javascript
  Scenario: Webhooks are not fired when I log in and browse the developer portal
    Given there are no enqueued jobs
    When I log in as "bob" on "foo.example.com"
    Then there should be no webhooks enqueued
    When I follow "Settings"
    Then there should be no webhooks enqueued
