@wip
Feature: Developer portal payment details

  Background:
    Given a provider
    And a product "The API"
    And the following application plan:
      | Product | Name | default |
      | The API | Pro  | true    |
    And a buyer "Jane" signed up to the product
    And the following application:
      | Buyer | Name       | Product |
      | Jane  | Jane's App | My API  |
    And the buyer logs in

  Rule: Backend v1
    Background:
      Given the product uses backend v1

    Scenario: Paid plan with prepaid billing
      Given the date is 1st January 2023
      Given the provider has "multiple_applications" denied
      And the provider is charging its buyers in prepaid mode
      And plan "Pro" has a monthly fee of 200
      And they go to the dev portal API access details page
      Then I should see "Not enough credit"
      And I should not see "Payment details required"
    # TODO: upload credit, then check that the warning dissapears

    Scenario: Paid plan with postpaid billing
      Given the date is 1st January 2023
      Given the provider has "multiple_applications" denied
      And the provider is charging its buyers in postpaid mode
      And plan "Pro" has a monthly fee of 200
      And they go to the dev portal API access details page
      And they should see "Payment details required"
      But should not see "Not enough credit"
      When they follow "credit card details"
      And follow "Add Details"
      And the form is submitted with:
        | First name              | Alice                     |
        | Last name               | From wonderland           |
        | Card number             | 1                         |
        | Card verification value | 999                       |
        | 2015                    | account_credit_card_year  |
        | 1 - January             | account_credit_card_month |
        | Address                 | C/Llacuna 162             |
        | City                    | Barcelona                 |
      And follow "Dashboard"
      And follow "API Access Details"
      Then should not see "Payment details required"
      And should not see "Not enough credit"

    Scenario: Provider verification key disabled
      When they go to the dev portal API access details page
      Then they should not see "Provider Verification Key"
