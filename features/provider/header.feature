@javascript
Feature: Header buttons and menus
  Background:
    Given a provider is logged in

  Scenario: Help menu dropdown
    Given quickstarts is disabled
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

  Scenario: Show and hide global navigation
    Given the sidebar navigation is not collapsible
    When they go to the accounts admin page
    Then the sidebar navigation is collapsible
