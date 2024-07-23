@javascript
Feature: Application details card

  Background:
    Given a provider
    And a product "My API"
    And the following application plan:
      | Product | Name |
      | My API  | Free |
    And a buyer "Jane"
    And the following application:
      | Buyer | Name   | Product |
      | Jane  | My App | My API  |
    And the provider logs in

  Scenario: Navigation
    Given the current page is the provider dashboard
    When they select "Audience" from the context selector
    And press "Applications" within the main menu
    And press "Accounts" within the main menu
    And follow "Listing" within the main menu
    And follow "My App"
    Then the current page is the application's admin page

  Scenario: Application details
    Given they go to the application's admin page
    Then they should see "Jane" within the application details
    And should see "My API" within the application details
    And should see "Live" within the application details

  Scenario: It shows Application expiration date when application contract is on trial
    Given the application has a trial period of 10 days
    When they go to the application's admin page
    Then they should see "trial expires in 10 days" within the application details

  Scenario: Suspending the application
    Given they go to the application's admin page
    When they follow "Suspend" and confirm the dialog within the application details
    Then they should see the flash message "The application has been suspended"
    And should see "Suspended" within the application details

  Scenario: Resuming the application
    Given the application is suspended
    And they go to the application's admin page
    When they follow "Resume" within the application details
    Then they should see the flash message "The application is live again!"
    And should see "Live" within the application details

  Scenario: Extra fields are listed alongside the application details
    Given the provider has the following fields defined for applications:
      | label             | required | read_only | hidden |
      | Recovery email    | true     |           |        |
      | Verification code |          | true      |        |
      | Hidden field      |          |           | true   |
    And the application has the following extra fields:
      | Recovery email    | This is a required field |
      | Verification code |                          |
      | Hidden field      | Hidden content           |
    When they go to the application's admin page
    Then they should see the following details within the application details:
      | Recovery email | This is a required field |
      | Hidden field   | Hidden content           |
    But should not see "User extra read only" within the application details
