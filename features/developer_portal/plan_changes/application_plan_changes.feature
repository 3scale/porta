@ignore-backend @javascript
Feature: Application Plan Change
  As a buyer
  I want to change plan

  Background:
    Given a provider exists
    And all the rolling updates features are off
    And the provider has a default free application plan
    And the provider has a paid application plan
    And a buyer signed up to the provider

  Scenario: Direct plan change
    Given the provider service allows to change application plan directly

    And I want to change the plan of my application to paid
    And I press "Change Plan"
    Then I should see "Plan change was successful."
    And a message should be sent from buyer to provider with plan change details from free to paid

  Scenario: Plan change by request
    Given the provider service allows to change application plan by request
    And I want to change the plan of my application to paid
    And I press "Request Plan Change"
    Then I should see "A request to change your application plan has been sent."
    And a message should be sent from buyer to provider requesting to change plan to paid

  Scenario: Change plan workflow dependent on credit card presence
    Given the provider service allows to change application plan only with credit card
    And I want to change the plan of my application to paid
    And I press "Request Plan Change"
    Then I should see "A request to change your application plan has been sent."

    Given the buyer has a valid credit card
    And I go to my application page
    And I want to change the plan of my application to paid

    And I press "Change Plan"
    Then I should see "Plan change was successful."
    And a message should be sent from buyer to provider with plan change details from free to paid

  Scenario: Change plan workflow with credit card required without wizard
    Given the provider service allows to change application plan with credit card required
    And the provider is charging its buyers with braintree

    And I want to change the plan of my application to paid

    And I follow "enter your Credit Card details"
    Then I should be at url for the braintree credit card details page

  # This is the default behaviour for new provider as of 05-07-2016
  Scenario: Change plan workflow with credit card required with wizard
    Given the provider service allows to change application plan with credit card required
    And the provider is charging its buyers with braintree
    And the provider has "finance" switch visible

    And the provider has all the templates setup

    And I want to change the plan of my application to paid
    Then I enter my credit card details
    And I press "Confirm"
    Then I should see "Plan change was successful."
    And a message should be sent from buyer to provider with plan change details from free to paid

  # This is the behaviour for existing provider as of 05-07-2016
  Scenario: Change plan workflow with credit card required without wizard
    Given the provider service allows to change application plan with credit card required
    And the provider is charging its buyers with braintree
    And the provider has "finance" switch visible

    And the provider has all the templates setup

    And provider has opt-out for credit card workflow on plan changes

    And I want to change the plan of my application to paid
    And I follow "enter your Credit Card details"
    Then I should be at url for the braintree credit card details page
    And the buyer adds their credit card details for Braintree


  # FIXME: Should we put an access denied or a better error message?
  Scenario: Change plan workflow with credit card required and payment gateway not configured
    Given the provider service allows to change application plan with credit card required
    And the provider is charging its buyers with stripe
    But the provider's payment gateway is unconfigured
    And the provider has "finance" hidden

    And I want to change the plan of my application to paid
    And I follow "enter your Credit Card details"
    Then I should see "Access denied"
#    Then I should see "We cannot charge you at the moment, our payment gateway is not setup. Sorry for the inconvenience"
