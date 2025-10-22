@javascript
Feature: Audience > Messages > Settings > Support emails

  As a provider I want to be able to manage my support email addresses. I want to be able to set a
  support email address for all kinds of inquiries and a specific one for all finance inquiries.
  Finally, I want to be able to specify a custom support email address for each of my products
  individually.

  Background:
    Given a provider with:
      | Support email         | support@api.test         |
      | Finance support email | finance-support@api.test |
    And the provider has "finance" switch allowed
    And the provider logs in

  Scenario: Finance support email not defined
    Given the provider has finance support email set to ""
    When they go to the emails settings page
    Then the provider's finance support email should be "support@api.test"

  Scenario: Update support and finance support emails
    Given they go to the emails settings page
    And the "Support email" field should contain "support@api.test"
    And the "Finance support email" field should contain "finance-support@api.test"
    When the form is submitted with:
      | Support email         | foo@api.test         |
      | Finance support email | finance-foo@api.test |
    Then they should see the flash message "Your support emails have been updated"
    And the provider's support email should be "foo@api.test"
    And the provider's finance support email should be "finance-foo@api.test"

  Scenario: Product without a specific support email uses the default one
    Given a product "Bananas"
    And the provider has support email set to "support@api.test"
    Then the product's support email should be "support@api.test"

  Scenario: Add a custom support email to a product
    Given a product "Bananas"
    And they go to the emails settings page
    When they press "Add a custom support email"
    And select the product "Bananas"
    And they should see button "Add a custom support email" disabled
    And fill in "Bananas" with "help@bananas.org"
    And press "Save support email for Bananas"
    And 1 second pass
    Then they should see a toast alert with text "Support email updated successfully"
    And the product's support email should be "help@bananas.org"

  Scenario: Edit a custom support email of a product
    Given a product "Bananas"
    And product "Bananas" has support email set to "old-help@bananas.org"
    And they go to the emails settings page
    When they press "Edit support email for Bananas"
    And fill in "Bananas" with "new-help@bananas.org"
    And press "Save support email for Bananas"
    And 1 second pass
    Then they should see a toast alert with text "Support email updated successfully"
    And the product's support email should be "new-help@bananas.org"

  Scenario: Remove a custom support email of a product
    Given a product "Bananas"
    And product "Bananas" has support email set to "help@bananas.org"
    And they go to the emails settings page
    When they press "Remove support email for Bananas"
    And confirm the dialog
    And 1 second pass
    Then they should see a toast alert with text "Custom support email removed from product"
    And the product's support email should be "support@api.test"

  Scenario: DNS domains are readonly
    Given DNS domains are readonly
    When they go to the emails settings page
    Then they should see "Outbound Email Addresses"

  Scenario: DNS domains are not readonly
    Given DNS domains are not readonly
    When they go to the emails settings page
    Then they should not see "Outbound Email Addresses"

  Scenario: Validation error for invalid support email format
    Given they go to the emails settings page
    When the form is submitted with:
      | Support email | hola@adios |
    Then field "Support email" has inline error "should look like an email address"
    And the provider's support email should still be "support@api.test"

  Scenario: Validation error for invalid finance support email format
    Given they go to the emails settings page
    When the form is submitted with:
      | Finance support email | invalid@email |
    Then field "Finance support email" has inline error "should look like an email address"
    And the provider's finance support email should still be "finance-support@api.test"

  Scenario: Multiple products have custom support emails
    Given a product "Bananas"
    And a product "Oranges"
    And product "Bananas" has support email set to "help@bananas.org"
    And product "Oranges" has support email set to "support@oranges.com"
    And they go to the emails settings page
    Then they should see the following custom support emails:
      | Bananas | help@bananas.org    |
      | Oranges | support@oranges.com |

  Scenario: Cannot add duplicate custom support email for same product
    Given a product "Bananas"
    And product "Bananas" has support email set to "help@bananas.org"
    And they go to the emails settings page
    When they press "Add a custom support email"
    Then they should see "API" within the modal
    But they should not see "Bananas" within the modal

  Scenario: Validation error for invalid custom product support email
    Given a product "Bananas"
    And they go to the emails settings page
    When they press "Add a custom support email"
    And select the product "Bananas"
    And fill in "Bananas" with "invalid@email"
    And press "Save support email for Bananas"
    And 1 second pass
    Then they should see a danger toast alert with text "Couldn't update support email"
    And the product's support email should still be "support@api.test"

  Scenario: Cancel adding custom support email
    Given a product "Bananas"
    And they go to the emails settings page
    When they press "Add a custom support email"
    And select the product "Bananas"
    And fill in "Bananas" with "help@bananas.org"
    And they should see button "Add a custom support email" disabled
    And press "Cancel"
    Then they should see button "Add a custom support email" enabled
    And they should see no custom support emails
    And the product's support email should be "support@api.test"

  Scenario: Cancel editing a custom support email
    Given a product "Bananas"
    And the product has support email set to "help@bananas.org"
    And they go to the emails settings page
    When they press "Edit support email for Bananas"
    And they should see button "Add a custom support email" disabled
    And fill in "Bananas" with "support@bananas.com"
    And press "Cancel edit of support email for Bananas"
    Then they should see button "Add a custom support email" enabled
    And there is a readonly field "Bananas"
    And the "Bananas" field should contain "help@bananas.org"

  Scenario: Finance support email shows only when provider has finance switch on
    Given they go to the emails settings page
    Then there is a field "Finance support email"
    But the provider has "finance" switch denied
    When they go to the emails settings page
    Then there is no field "Finance support email"
