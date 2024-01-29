Feature: Developer portal applications list page

  Background:
    Given a provider
    And a product "My API"
    And the following published application plan:
      | Product | Name  |
      | My API  | Basic |
    And a buyer "Jane"
    And the following application:
      | Buyer | Name       | Product |
      | Jane  | Jane's App | My API  |
    And the buyer logs in

  Rule: Multiple applications disabled
    Background:
      Given the provider has "multiple_applications" denied

    Scenario: There is no page for applications
      Given they go to the homepage
      Then there should not be a link to "Applications" within the navigation bar
      But there should be a link to "Jane's App"

  Rule: Multiple applications enabled
    Background:
      Given the provider has "multiple_applications" visible

    Scenario: No pagination
      Given they go to the homepage
      When they follow "Applications" within the navigation bar
      Then they should see "Jane's App"
      But they don't see the pagination

    Scenario: Pagination
      Given the buyer has 40 applications
      And they go to the homepage
      When they follow "Applications" within the navigation bar
      Then they see the pagination

    Scenario: Buyer can't create an application if subscription is pending approval
      Given the following service plan:
        | Product | Name | Requires approval |
        | My API  | Gold | true              |
      And the buyer is signed up to service plan "Gold"
      When they go to the dev portal applications page
      Then there should not be a link to "Create new application"

    Scenario: Buyer can't create an application without a published or default app plan
      Given the provider has no published application plans
      And the provider has no default application plan
      And the following service plan:
        | Product | Name | Requires approval |
        | My API  | Gold | false             |
      And the buyer is signed up to service plan "Gold"
      When they go to the dev portal applications page
      Then there should not be a link to "Create new application"
      When they go to the dev portal applications page
      Then there should not be a link to "Create new application"

    Scenario: Buyer can create an application if app plan is published
      Given the following service plan:
        | Product | Name | Requires approval |
        | My API  | Gold | false             |
      And the buyer is signed up to service plan "Gold"
      And application plan "Basic" is published
      When they go to the dev portal applications page
      Then there should be a link to "Create new application"

    Scenario: Buyer can create an application if a plan is default even though it's hidden
      Given the following service plan:
        | Product | Name | Requires approval |
        | My API  | Gold | false             |
      And the buyer is signed up to service plan "Gold"
      And the following application plan:
        | Product | Name  | State  | Default |
        | My API  | Trial | Hidden | True    |
      When they go to the dev portal applications page
      Then there should be a link to "Create new application"
