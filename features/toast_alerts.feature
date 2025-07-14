@javascript
Feature: Toast alert notifications

  As a user I want to see toast alert notifications that will automatically go away after 5 seconds.

  Background:
    Given a provider is logged in
    And they go to the provider dashboard

  Scenario Outline: Display toasts
    When a <type> toast alert is displayed with text "<message>"
    Then they should see a <type> toast alert with text "<message>"

    Examples:
      | type    | message            |
      | default | Hello Pepe!        |
      | info    | Info for Pepe      |
      | success | Pepe was a success |
      | warning | Watch out, Pepe!   |
      | danger  | Pepe alert!        |

  Scenario: Timeout
    When a toast alert is displayed with text "Notice for you."
    But after 8 seconds
    Then they should not see any toast alerts

  Scenario: Close alert manually
    Given a toast alert is displayed with text "This is closeable"
    When press "Close alert"
    Then they should not see any toast alerts
