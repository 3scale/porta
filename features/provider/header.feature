Feature: Header buttons and menus

  Background:
    Given a provider is logged in

  Scenario: Help menu dropdown
    Then the help menu should have the following items:
      | Customer Portal  |
      | 3scale API Docs  |
      | Liquid Reference |
      | What's new?      |

  Scenario: Help menu dropdown when Quickstarts enabled
    Given quickstarts is enabled
    Then the help menu should have the following items:
      | Customer Portal  |
      | 3scale API Docs  |
      | Liquid Reference |
      | What's new?      |
      | Quick starts     |
