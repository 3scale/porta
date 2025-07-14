@javascript
Feature: Update notification preferences
  As a provider user
  I'd like to update the notification preferences page correctly

  Background:
    Given a provider is logged in

  Scenario: Enable selected notifications
    When they go to the notification preferences page
    Then I should see "Notification Preferences"
    When they check only the following notifications:
      | New account created             |
      | Expiring credit card            |
      | Application plan change request |
      | Service plan change request     |
      | Alert: usage violation          |
      | Weekly report                   |
    And they press "Update Notification Preferences"
    Then they should see "Notification preferences successfully updated"
    And only the following notifications are checked:
      | New account created             |
      | Expiring credit card            |
      | Application plan change request |
      | Service plan change request     |
      | Alert: usage violation          |
      | Weekly report                   |

  Scenario: Disable all notifications
    When they go to the notification preferences page
    Then I should see "Notification Preferences"
    When they disable all notifications
    And they press "Update Notification Preferences"
    Then they should see "Notification preferences successfully updated"
    And all notifications are unchecked
