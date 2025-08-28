@javascript
Feature: Dashboard
  In order to navigate easily
  As a provider
  I want to have important links on the dashboard

  Background:
    Given a provider is logged in
    And All Dashboard widgets are loaded

  Scenario: Audience widget
    And I go to the provider dashboard
    Then I should see "AUDIENCE" within the audience dashboard widget
    And I should see the link "0 ACCOUNTS" within the audience dashboard widget
    And I should see the link "PORTAL" within the audience dashboard widget
    And I should see the link "0 DRAFTS" within the audience dashboard widget
    And I should see the link "0 MESSAGES" within the audience dashboard widget

  Scenario: Audience widget with Finance enabled
    Given the provider is charging its buyers
    And I go to the provider dashboard
    Then I should see the link "BILLING" within the audience dashboard widget

  Scenario: Messages link shows only unread messages count when there are unread messages
    And a buyer "john" signed up to provider "foo.3scale.localhost"
    And 5 messages sent from buyer "john" to the provider with subject "any" and body "any"
    And I go to the provider dashboard
    And I should see "5 UNREAD MESSAGES" within the audience dashboard widget

  Scenario: Messages link shows all messages count when there are no unread messages
    And a buyer "john" signed up to provider "foo.3scale.localhost"
    And 5 messages sent from buyer "john" to the provider with subject "any" and body "any"
    And the provider reads all messages
    And I go to the provider dashboard
    And I should see the link "5 MESSAGES" within the audience dashboard widget

  Scenario: Messages link shows correct count of unread messages when the size exceeds the limit
    And a buyer "john" signed up to provider "foo.3scale.localhost"
    And 110 messages sent from buyer "john" to the provider with subject "any" and body "any"
    And I go to the provider dashboard
    And I should see the link "100+ UNREAD MESSAGES" within the audience dashboard widget

  Scenario: Messages link shows correct count of messages when the size exceeds the limit
    And a buyer "john" signed up to provider "foo.3scale.localhost"
    And 110 messages sent from buyer "john" to the provider with subject "any" and body "any"
    And the provider reads all messages
    And I go to the provider dashboard
    And I should see the link "100+ MESSAGES" within the audience dashboard widget
