@javascript
Feature: Notification preferences
  As a member
  I'd like to see the notification preferences page correctly

  Scenario: No notification preferences available
    Given a provider "foo.example.com"
    And an active user "alex" of account "foo.example.com" with no permission
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "alex"
      And I go to the provider personal page
      And I follow "Notification Preferences"
    Then I should see "You don't have access to any notifications"

  Scenario: Some notification preferences available
    Given a provider "foo.example.com"
    And an active user "alex" of account "foo.example.com" with partners permission
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "alex"
    And I go to the provider personal page
    And I follow "Notification Preferences"
    Then I should not see "You don't have access to any notifications"
