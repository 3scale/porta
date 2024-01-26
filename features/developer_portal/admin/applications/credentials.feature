Feature: Developer portal application credentials

  Background:
    Given a provider
    And the provider has multiple applications enabled
    And a product "My API"
    And the following application plan:
      | Product | Name |
      | My API  | Free |
    And a buyer "Jane"
    And the buyer has an application "Jane's App" for the product
    And the buyer logs in

  Scenario: Regenerate user key
    Given the product has buyer key regenerate enabled
    And the application user key is "habba babba"
    And they go to the dev portal API access details page
    And they should see "habba babba"
    When they press "Regenerate"
    Then they should see the flash message "The user key was regenerated"
    And they should not see "habba babba"

  Scenario: Buyer Key Refresh disabled
    Given the product has buyer key regenerate disabled
    When they go to the dev portal API access details page
    Then there should not be a button to "Regenerate"

  Rule: Multiple applications enabled
    Background:
      Given the provider has "multiple_applications" visible

    Scenario: Navigation
      Given they go to the homepage
      When they follow "Applications" within the navigation bar
      And they follow "Jane's App"
      Then the current page is the application's dev portal page

  Rule: Multiple applications disabled
    Background:
      Given the provider has "multiple_applications" denied

    Scenario: Navigation
      Given they go to the homepage
      When they follow "API Credentials" within the navigation bar
      Then the current page is the application's dev portal page

  Rule: Backend v1
    Background:
      Given the product uses backend v1

    Scenario: Backend v1 uses a single user key
      When they go to the dev portal API access details page
      Then they should see the user key of "Jane"
      But there should not be a button to "Create new key"

  Rule: Oauth
    Background:
      Given the product uses backend oauth
      And the application has 3 keys

    Scenario: Oauth uses client secret and ID
      When they go to the dev portal API access details page
      Then they should see the following details:
        | Client ID     | 123                                 |
        | Client Secret | app-key                             |
        | Redirect URL  | This is your Redirect URL for OAuth |
      And there should be a button to "Regenerate"

  Rule: Backend v2
    Background:
      Given the product uses backend v2
      And the application has the following keys:
        | key-one |
        | key-two |

    Scenario: Backend v2 has multiple user keys
      When they go to the dev portal API access details page
      Then they should see "key-one" within the application keys
      And should see "key-two" within the application keys
      And there should be a button to "Create new key"

    Scenario: Provider can deny access to applications Keys
      Given the product does not allow buyers to manage application keys
      When they go to the application's dev portal page
      Then they should not see "Application Keys"
      And should not see "key-one"

    Scenario: Create key
      Given the backend will create key "key-one" for the application
      When they go to the application's dev portal page
      And press "Create new key"
      Then they should see "key-one" within the application keys

    Scenario: Application has a limit of 5 keys
      Given the application has the following keys:
        | key-one   |
        | key-two   |
        | key-three |
        | key-four  |
        | key-five  |
      When they go to the application's dev portal page
      Then they should see "At most 5 keys are allowed"

    Scenario: Can't delete last key when mandatory app key set
      Given the application has the following key:
        | key-one |
      And the product has mandatory app key set to "true"
      When they go to the application's dev portal page
      Then there should not be a button to delete key "key-one"

    Scenario: Delete last key when mandatory app key unset
      Given the application has the following key:
        | key-one |
      And the product has mandatory app key set to "false"
      When they go to the application's dev portal page
      And delete application key "key-one"
      Then they should see "Application key was deleted."
