@javascript
Feature: Service plan edit page

  Background:
    Given a provider is logged in
    And the provider has "service_plans" allowed
    And a product "My API"
    And the following service plan:
      | Product | Name |
      | My API  | Free |

  Scenario: Navigation
    Given they go to product "My API" service plans admin page
    When they follow "Free" within the table
    Then the current page is service plan "Free" admin edit page

  Scenario: Edit a service plan
    Given they go to service plan "Free" admin edit page
    And they should see "Service plan Free"
    When the form is submitted with:
      | Name                                    | Still free |
      | Service subscriptions require approval? | Yes        |
    Then the current page is the product's service plans admin page
    # And they should see "Plan was updated"
    And the table has the following row:
      | Name       |
      | Still free |

  Scenario: Edit an service plan with billing enabled
    # See app/views/api/plans/forms/_billing_strategy.html.erb
    Given the provider is charging its buyers
    And they go to service plan "Free" admin edit page
    When the form is submitted with:
      | Name           | Not free anymore |
      | Setup fee      | 100              |
      | Cost per month | 10               |
    Then the current page is the product's service plans admin page
    # And they should see "Plan was updated"
    And the table has the following row:
      | Name             |
      | Not free anymore |

  @wip
  Scenario: Form validation
