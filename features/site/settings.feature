@javascript
Feature: Credit Card policies

  Rule: Provider
    Background:
      Given a provider is logged in
      And the provider has "finance" allowed

    Scenario: Navigate to Credit Card policies
      When they press "Dashboard"
      And they follow "Audience"
      And they press "Billing"
      And they press "Settings" within the main menu's section Billing
      And they follow "Credit Card Policies"
      Then the current page is the edit site settings page

    Scenario: Set up paths to legal terms, privacy and refunds pages
      Given they go to the edit site settings page
      When they fill in "Path to Legal Terms page" with "/legal-terms-page"
      And they fill in "Path to Privacy page" with "/privacy-page"
      And they fill in "Path to Refund page" with "/refund-page"
      And press "Save"
      Then they should see "Settings updated."

  Rule: Master
    Background:
      Given master is the provider
      And master admin is logged in

    Scenario: Set up paths to legal terms, privacy and refunds pages
      Given they go to the edit site settings page
      When they fill in "Path to Legal Terms page" with "/legal-terms-page"
      And they fill in "Path to Privacy page" with "/privacy-page"
      And they fill in "Path to Refund page" with "/refund-page"
      And press "Save"
      Then they should see "Settings updated."
