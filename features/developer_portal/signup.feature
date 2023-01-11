Feature: Buyer signup
  I want to signup as a buyer
  Background:
    Given a provider exists
    And master has a application plan "enterprise"
    And the provider account allows signups

  @javascript
  Scenario: Signup creates account created event
    And there are no events
    When a buyer signs up
    Then I should see "We have sent you an email to confirm your email address."

    Then there should be 1 valid account created event
      And there should be 1 valid application created event
      And there should be 1 valid service contract created event
      And all the events should be valid
      And the users should receive the application created notification email
      And the users should receive the account created notification email
      And the users should receive the service contract created notification email

  # This is the default behaviour for new providers as of 05-07-2016
  @javascript
  Scenario: Signup forces to fill in credit card for paid plan
    Given the provider is charging its buyers with braintree
    And the provider has "finance" visible
    And has a buyer with application plan
    And application plan is paid
    And the provider has credit card on signup feature in automatic mode
    And the provider upgrades to plan "enterprise"
    Then the provider should have credit card on signup switch visible
    When the buyer logs in to the provider
    Then I should be on the edit credit card details page
    And I should be warned to complete my signup

  # This is the behaviour for existing providers as of 05-07-2016
  @javascript
  Scenario: Signup does not require to fill in credit card on paid plan
    And the provider is charging its buyers with braintree

    And has a buyer with application plan
    And application plan is paid
    And the provider has credit card on signup feature in manual mode
    And the provider upgrades to plan "enterprise"
    Then the provider should have credit card on signup switch hidden

    When the buyer logs in to the provider
    Then I should be on the homepage

  # This is the behaviour for existing providers as of 05-07-2016
  @javascript
  Scenario: Signup require to fill in credit card on paid plan if switch is enabled
    And the provider is charging its buyers with braintree
    And the provider has "finance" visible

    And has a buyer with application plan
    And application plan is paid
    And the provider has credit card on signup feature in manual mode
    And the provider upgrades to plan "enterprise"
    Then the provider should have credit card on signup switch hidden

    And the provider enables credit card on signup feature manually
    Then the provider should have credit card on signup switch visible

    When the buyer logs in to the provider

    Then I should be on the edit credit card details page
    And I should be warned to complete my signup

  @recaptcha
  Scenario: Spam protection detects suspicious behavior
    Given the provider has spam protection set to suspicious only
    When the buyer wants to sign up
    Then the buyer doesn't need to pass the captcha after signup form is filled wrong
    But the buyer will need to pass the captcha after signup form is filled in too quickly