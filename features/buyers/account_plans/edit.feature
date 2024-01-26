@javascript
Feature: Account plan edit page

  Background:
    Given a provider is logged in
    And the provider has "account_plans" allowed
    And the following account plan:
      | Issuer               | Name |
      | foo.3scale.localhost | Free |

  Scenario: Navigation
    Given they go to the account plans admin page
    When they follow "Free" within the table
    Then the current page is account plan "Free" admin edit page

  Scenario: Edit an account plan
    Given they go to account plan "Free" admin edit page
    And they should see "Account plan Free"
    When the form is submitted with:
      | Name                       | Still free |
      | Accounts require approval? | Yes        |
    Then the current page is the account plans admin page
    # And they should see "Plan was updated"
    And the table has the following row:
      | Name       |
      | Still free |

  @wip
  Scenario: Edit an account plan with billing enabled
    # See app/views/api/plans/forms/_billing_strategy.html.erb
    Given billing is enabled
    And they go to account plan "Free" admin edit page
    When the form is submitted with:
      | Name           | Not free anymore |
      | Setup fee      | 100              |
      | Cost per month | 10               |
    Then the current page is the account plans admin page
    And they should see "Plan was updated"
    And the table has the following row:
      | Name             |
      | Not free anymore |

  @wip
  Scenario: Form validation
