@javascript
Feature: Master edits provider admin domain

  Background:
    Given master admin is logged in
    And the default product of provider "master" has name "Master API"
    And the following application plan:
      | Product    | Name  | State     |
      | Master API | Basic | Published |
    And a provider "banana.example.org" signed up to plan "Basic"

  Scenario: Master can see the admin domain field on the provider edit page
    When they go to the buyer account edit page for "banana.example.org"
    Then they should see "Admin domain"

  Scenario: Master sees a confirmation dialog when changing the admin domain
    When they go to the buyer account edit page for "banana.example.org"
    And the form is submitted with:
      | Admin domain | new-admin.banana.example.org |
    Then they should see "Change admin portal domain?"
    And they should see "SSL certificate"
    And they should see "Active sessions"
    And they should see "Email links"
    And they should see "Provider Admin SSO"

  Scenario: Master cancels the admin domain change
    When they go to the buyer account edit page for "banana.example.org"
    And the form is submitted with:
      | Admin domain | new-admin.banana.example.org |
    Then they should see "Change admin portal domain?"
    When they press "Cancel"
    Then they should not see "Change admin portal domain?"

  Scenario: Master confirms the admin domain change
    When they go to the buyer account edit page for "banana.example.org"
    And the form is submitted with:
      | Admin domain | new-admin.banana.example.org |
    Then they should see "Change admin portal domain?"
    When they press "Confirm"
    Then should see a toast alert with text "Account successfully updated"
    And the current page is the overview page of account "banana.example.org"

  Scenario: No confirmation dialog when admin domain is not changed
    When they go to the buyer account edit page for "banana.example.org"
    And they press "Update Account"
    Then they should not see "Change admin portal domain?"
    Then should see a toast alert with text "Account successfully updated"
    And the current page is the overview page of account "banana.example.org"
