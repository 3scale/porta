@javascript
Feature: Application plan edit page

  Background:
    Given a provider is logged in
    And a product "My API"
    And the following application plan:
      | Product | Name |
      | My API  | Free |

  Scenario: Navigation
    Given they go to the product's application plans admin page
    When they follow "Free" within the table
    Then the current page is application plan "Free" admin edit page

  Scenario: Edit an application plan
    Given they go to application plan "Free" admin edit page
    And they should see "Application Plan Free"
    And there is no field "Trial Period (days)"
    And there is no field "Setup free"
    And there is no field "Cost per month"
    When the form is submitted with:
      | Name                           | Still free |
      | Applications require approval? | Yes        |
    # Then they should see the flash message "Plan was updated"
    And the table has the following row:
      | Name       |
      | Still free |

  Scenario: Edit an application plan when billing enabled
    Given the provider is charging its buyers
    And they go to application plan "Free" admin edit page
    When the form is submitted with:
      | Name                           | Now paid! |
      | Applications require approval? | Yes       |
      | Trial Period (days)            | 30        |
      | Setup fee                      | 10        |
      | Cost per month                 | 5         |
    # Then they should see the flash message "Plan was updated"
    And the table has the following row:
      | Name      |
      | Now paid! |

  @wip
  Scenario: Edit an application plan with billing enabled
    # See app/views/api/plans/forms/_billing_strategy.html.erb
    Given billing is enabled
    And they go to application plan "Free" admin edit page
    When the form is submitted with:
      | Name           | Not free anymore |
      | Setup fee      | 100              |
      | Cost per month | 10               |
    Then the current page is the product's application plans admin page
    And they should see "Plan was updated"
    And the table has the following row:
      | Name             |
      | Not free anymore |

  @wip
  Scenario: Form validation
