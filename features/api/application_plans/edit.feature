@javascript
Feature: Application approval required

  Background:
    Given a provider is logged in
    And a product "My API"
    And the following application plan:
      | Product | Name |
      | My API  | Free |

  Scenario: Make new applications require approval from admin
    Given they go to application plan "Free" admin edit page
    When the form is submitted with:
      | Applications require approval? | Yes |
    Then the current page is the product's application plans admin page
    And new applications with application plan "Free" will be pending for approval
