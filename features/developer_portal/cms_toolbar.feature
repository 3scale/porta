@javascript
Feature: CMS Toolbar

  In order to easily change and update the developer portal, I want to see a sidebar to the right
  listing all the templates used in the current page. Moreover I want to change between draft and
  published versions with ease, and be able to hide such sidebar to see the full page.

  Background:
    Given a provider is logged in

  Scenario: A buyer logs in
    Given a buyer "Cake"
    When the buyer logs in
    And go to the homepage
    Then there should not be a CMS toolbar

  Scenario: Hide the toolbar
    When they visit the developer portal in CMS mode
    And follow "Draft"
    And press "Toggle toolbar"
    Then the cms toolbar shouldn't be visible

  Scenario: The toolbar was previously hidden
    Given the CMS toolbar has been previously hidden
    When they visit the developer portal in CMS mode
    Then the cms toolbar shouldn't be visible
    But they press "Toggle toolbar"
    And the cms toolbar should be visible

  Scenario:
    When they visit the developer portal in CMS mode
    And follow "Published"
    And follow "Close the CMS toolbar"
    Then there should not be a CMS toolbar

  Rule: There is a John Doe admin user
    Background:
      When the admin user is John Doe

    Scenario: An admin visist de dev portal
      When they visit the developer portal in CMS mode
      Then the cms toolbar should be visible
      And should see "Templates used on this page"
      And should see the following details:
        | Username | john   |
        | Password | 123456 |
      And should see "Color Theme"
