@javascript
Feature: CMS sidebar
  As a provider
  The CMS sidebar is used to navigate and manage content

  Background:
    Given a provider is logged in
    And the provider has the following sections:
      | Title   |
      | About   |
      | Support |
    And the provider has the following pages:
      | Title     | Path       | Section |
      | Welcome   | /welcome   | Root    |
      | About Us  | /about-us  | About   |
    And a dev portal partial "shared_header"
    And a dev portal layout "custom_layout"
    And they go to the CMS page
    And wait a moment

  Scenario: Sidebar displays all content sections
    Then they should see "Root" within the CMS sidebar
    And they should see "About" within the CMS sidebar
    And they should see "Support" within the CMS sidebar
    And they should see "Welcome" within the CMS sidebar
    And they should see "About Us" within the CMS sidebar
    And they should see "Layouts" within the CMS sidebar
    And they should see "Partials" within the CMS sidebar

  Scenario: Clicking a page navigates to its edit page
    When they follow "Welcome" within the CMS sidebar
    Then they should see "Page 'Welcome'"

  Scenario: Clicking a section navigates to its edit page
    When they follow "About" within the CMS sidebar
    Then they should see "Section 'About'"

  Scenario: Current page is highlighted in sidebar
    When they follow "Welcome" within the CMS sidebar
    And wait a moment
    Then they should see the sidebar item "Welcome" highlighted

  Scenario: Toggling a section collapses and expands it
    When they toggle the sidebar section "About"
    Then the sidebar section "About" should be collapsed
    When they toggle the sidebar section "About"
    Then the sidebar section "About" should be expanded

  Scenario: Collapse all button packs all sections
    When they click on the collapse all button in the CMS sidebar
    Then all top-level sidebar sections should be collapsed
    When they click on the collapse all button in the CMS sidebar
    Then all top-level sidebar sections should be expanded

  Scenario: Filter sidebar by text search
    When they fill in the CMS sidebar filter with "Welcome"
    Then they should see "Welcome" within the CMS sidebar
    And they should not see "About Us" within the CMS sidebar

  Scenario: Clearing the filter shows all items
    When they fill in the CMS sidebar filter with "Welcome"
    And they fill in the CMS sidebar filter with ""
    Then they should see "Welcome" within the CMS sidebar
    And they should see "About Us" within the CMS sidebar

  Scenario: Toggle state persists across page loads
    When they toggle the sidebar section "About"
    Then the sidebar section "About" should be collapsed
    And the toggle cookie should contain the section "About"
    When they go to the CMS page
    And wait a moment
    Then the sidebar section "About" should be collapsed
