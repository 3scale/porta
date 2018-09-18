@wip
Feature: Contributor role
  In order to manage content in my organization
  As a contributor
  I want to have access to create/update the content

  Background:
    Given a provider "your.acme.com"
    And an user "alice" of account "your.acme.com"
    And a contributor "bob" of account "your.acme.com"

  Scenario: Admin can activate contributors
    When I log in as "your.acme.com"
      And I go to the users page
      And I follow "edit" within the row for user "alice"
    Then I should see "Contributor"

    When I choose "Contributor"
      And I press "Update"
    Then I should see "User was successfully updated."
      And "alice" should be a contributor

  Scenario: Contributor allowed content
    When I log in as "bob" on your.acme.com
    Then I should be redirected to "http://your.acme.com/"

    And I should see "Portal"
      But I should not see "Dashboard"
      But I should not see "SDK"
      But I should not see "Partners"

    When I follow "Portal"
    Then I should see "Sitemap"
      And I should see "Content"
      And I should see "Partials"
      And I should see "Layouts"
    But I should not see "Redirects"
      But I should not see "SDK"
      But I should not see "Streams"

  Scenario: Contributor can create content
      And current domain is the admin domain of provider "foo.example.com"
      And I log in as "bob"
      And I follow "Add New Content"
    Then I should be on the new html block page

    When I fill in the following:
      | Name        | Test Html Block                   |
      | Content     | Content created by a contributor  |
      And I press "Save"
    Then I should see "Text 'Test Html Block' was created"

