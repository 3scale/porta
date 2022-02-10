Feature: Header buttons and menus

  Background:
    Given a provider is logged in

  Scenario: Help menu dropdown
    Then I should see the following help menu items:
      | Customer Portal  |
      | 3scale API Docs  |
      | Liquid Reference |
      | What's new?      |
      | Quick starts     |
