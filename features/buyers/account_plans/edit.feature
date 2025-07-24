@javascript
Feature: Account approval required

  Background:
    Given a provider is logged in
    And the provider has "account_plans" allowed
    And the following account plan:
      | Issuer               | Name |
      | foo.3scale.localhost | Free |

  Scenario: Make new accounts require approval from admin
    Given they go to account plan "Free" admin edit page
    When the form is submitted with:
      | Accounts require approval? | Yes        |
    Then the current page is the account plans admin page
    And new accounts with account plan "Free" will be pending for approval
