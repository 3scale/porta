Feature: XSS protection
  As a buyer
  I want to be safe against XSS attacks

  Background:
    Given a provider exists
    And the default product of the provider has name "My API"
    And the following application plan:
      | Product | Name    | Default |
      | My API  | Default | true    |
    And an approved buyer "John" signed up to the provider
    And the following application:
      | Buyer | Name   |
      | John  | My App |

  @javascript
  Scenario: Inline javascript attempted into error messages rendered
    When the buyer logs in
    And I open an URL with XSS exploit
    Then I should see "Granularity must be one of [:month, :day, 6 hours, :hour], not 123<img src='1' onerror='confirm(/XSS/)'>"
