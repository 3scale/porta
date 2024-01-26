Feature: Audience menu
  In order to manage my audience
  As a provider
  I want to see a menu that lets me do that

  Background:
    Given a provider
    And a product "My API"
    And the following application plan:
      | Product | Name |
      | My API  | Free |
    And a buyer "Bob"
    And the buyer has an application "My App" with plan "Free"
    And the provider logs in

  @javascript
  Scenario: Application overview
    When they go to the application's admin page
    Then I should see there is no current API
