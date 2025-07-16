Feature: Dev Portal Buyer Personal Details SSO
  As a buyer
  I want to change my personal details
  After I log in with SSO

  Background:
    Given Provider has setup RH SSO
    And As a developer, I see RH-SSO login option on the login page
    And the Oauth2 user has all the required fields
    And I authenticate by Oauth2

  Scenario: Buyer shouldn't see any password input
    Given they go to the personal details page
    And I should not see the fields:
      | hidden fields         |
      | Current password      |
      | New password          |
      | Password confirmation |
      | Account extra hidden  |

  @javascript
  Scenario: Buyer can edit their personal details
    Given they go to the personal details page
    And the current page is the personal details page
    When they edit their personal details
    Then they should be able to edit their personal details
