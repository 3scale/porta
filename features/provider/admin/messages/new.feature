@javascript
Feature: Audience > Messages > Outbox > New

  Background:
    Given a provider is logged in

  Scenario: Message can't be sent without subject
    Given they go to the outbox compose page
    And fill in "Body" with "Subject is empty"
    And press "Send"
    Then should see "Compose"
    And the current page is the outbox compose page

  Scenario: Message can't be sent without body
    Given they go to the outbox compose page
    And fill in "Subject" with "Body is empty"
    And press "Send"
    Then should see "Compose"
    And the current page is the outbox compose page
