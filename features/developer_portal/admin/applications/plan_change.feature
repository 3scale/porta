@javascript
Feature: Developer portal change application plan

  Background:
    Given a provider "foo.3scale.localhost"
    And admin of account "foo.3scale.localhost" has email "admin@foo.3scale.localhost"
    And the provider has "multiple_services" visible
    And the provider has "service_plans" visible
    And a product "The API"
    And the following published application plans:
      | Product | Name       | Cost per month | Default |
      | The API | Developer  |                | true    |
      | The API | Enterprise | 100            |         |
    And a buyer "Jane" signed up to service "The API"
    And the following application:
      | Buyer | Name   | Plan      |
      | Jane  | My App | Developer |
    And the buyer logs in

  Scenario: Change an application's plan requires approval
    Given they go to the application's dev portal edit page
    When follow "Review/Change"
    And follow "Enterprise"
    And press "Request Plan Change"
    Then should see the flash message "A request to change your application plan has been sent"
    And "admin@foo.3scale.localhost" should receive an email with subject "Action required: Jane from Jane requested an app plan change"

  Scenario: Change an application's plan directly
    Given all the rolling updates features are off
    And the product allows to change application plan directly
    When they go to the application's dev portal edit page
    And follow "Review/Change"
    And follow "Enterprise"
    And press "Change Plan"
    Then should see the flash message "Plan change was successful."
    And "admin@foo.3scale.localhost" should receive an email with subject "Application My App has changed to plan Enterprise"

  Scenario: Without a credit card, changing an application's plan requires approval
    Given all the rolling updates features are off
    And the product allows to change application plan only with credit card
    When they go to the application's dev portal edit page
    And follow "Review/Change"
    And follow "Enterprise"
    And press "Request Plan Change"
    Then they should see "A request to change your application plan has been sent."
    And "admin@foo.3scale.localhost" should receive an email with subject "Action required: Jane from Jane requested an app plan change"

  Scenario: With a valid credit card, an application's plan can be changed directly
    Given all the rolling updates features are off
    And the product allows to change application plan only with credit card
    And the buyer has a valid credit card
    When they go to the application's dev portal edit page
    And follow "Review/Change"
    And follow "Enterprise"
    And press "Change Plan"
    Then they should see "Plan change was successful."

  Scenario: Change plan workflow with credit card required without wizard
    Given the product allows to change application plan with credit card required
    And the provider is charging its buyers with braintree
    When they go to the application's dev portal edit page
    And follow "Review/Change"
    And follow "Enterprise"
    And follow "enter your Credit Card details"
    Then the current page is the braintree credit card details page

  # This is the default behaviour for new provider as of 05-07-2016
  Scenario: Change plan workflow with credit card required with wizard
    Given the product allows to change application plan with credit card required
    And the provider is charging its buyers with braintree
    And the provider has "finance" visible
    And the provider has all the templates setup
    When they go to the application's dev portal edit page
    And follow "Review/Change"
    And follow "Enterprise"
    # TODO: We need to mock useBraintreeHostedFields for this test work, or the form won't even submit
    # Then I enter my credit card details
    # And I press "Confirm"
    # Then I should see "Plan change was successful."
    # And a message should be sent from buyer to provider with plan change details from free to paid

  # This is the behaviour for existing provider as of 05-07-2016
  Scenario: Change plan workflow with credit card required without wizard
    Given the product allows to change application plan with credit card required
    And the provider is charging its buyers with braintree
    And the provider has "finance" switch visible
    And the provider has all the templates setup
    And provider has opt-out for credit card workflow on plan changes
    When they go to the application's dev portal edit page
    And follow "Review/Change"
    And follow "Enterprise"
    And follow "enter your Credit Card details"
    Then the current page is the braintree credit card details page
    # TODO: We need to mock useBraintreeHostedFields for this test work, or the form won't even submit
    # And the buyer adds their credit card details for Braintree

  # FIXME: Should we put an access denied or a better error message?
  Scenario: Change plan workflow with credit card required and payment gateway not configured
    Given the product allows to change application plan with credit card required
    And the provider is charging its buyers with stripe
    But the provider's payment gateway is unconfigured
    And the provider has "finance" hidden
    When they go to the application's dev portal edit page
    And follow "Review/Change"
    And follow "Enterprise"
    And follow "enter your Credit Card details"
    Then they should see "Access denied"
    # Then I should see "We cannot charge you at the moment, our payment gateway is not setup. Sorry for the inconvenience"
