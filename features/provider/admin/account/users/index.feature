@javascript
Feature: Account Settings > Users > Listing

  Background:
    Given a provider
    And the provider has no users
    But the following users:
      | Username | First name | Last name | Role   | Email                |
      | wesker   | Albert     | Wesker    | admin  | wesker@umbrella.corp |
      | hunk     |            |           | member | hunk@umbrella.corp   |
      | awong    | Ada        | Wong      | member | awong@umbrella.corp  |

  Scenario: User page requires login
    Given user is not logged in
    When they go to the provider users page
    Then the current page is the provider login page

  @security @allow-rescue
  Scenario: Members can't access users page
    Given user "hunk" logs in
    When they select "Account Settings" from the context selector
    Then there should not be a button to "Users" within the main menu
    And there should not be a link to the provider users page
    When they go to the provider users page
    Then they should be denied the access

  Rule: User is an admin
    Background:
      And the provider logs in

    Scenario: Navigation
      When they select "Account Settings" from the context selector
      And they press "Users" within the main menu
      And follow "Listing" within the main menu
      Then the current page is the provider users page

    Scenario: Admin can only see user from its provider
      Given another provider "sunshade.3scale.localhost"
      And the following users:
        | Username | Role  | Email             |
        | jsmith   | admin | john@sunshade.org |
      When they go to the provider users page
      Then they should see the following table:
        | Email                | Role   |
        | wesker@umbrella.corp | admin  |
        | hunk@umbrella.corp   | member |
        | awong@umbrella.corp  | member |
      And they should not see "jsmith" within the table

    Scenario: First column is the user full name or username
      When they go to the provider users page
      Then they should see the following table:
        | Name          |
        | Albert Wesker |
        | hunk          |
        | Ada Wong      |

    Scenario: Permission groups are listed in the table
      Given user "hunk" has finance permission
      And user "awong" has partners permission
      When they go to the provider users page
      Then they should see the following table:
        | Name          | Permission groups                |
        | Albert Wesker | Unlimited access                 |
        | hunk          | Customer Billing                 |
        | Ada Wong      | Developer accounts, Applications |

    Scenario: Admin can delete users from then table
      Given they go to the provider users page
      When they select action "Delete" of "hunk"
      And confirm the dialog
      Then they should see the flash message "User was successfully deleted"
      And they should see the following table:
        | Name          | Email                | Role   | Permission groups |
        | Albert Wesker | wesker@umbrella.corp | admin  | Unlimited access  |
        | Ada Wong      | awong@umbrella.corp  | member | -                 |

    Scenario: Admin can edit users from the table
      Given they go to the provider users page
      And they select action "Edit" of "hunk"
      When the form is submitted with:
        | Username | honk               |
        | Email    | honk@umbrella.corp |
      Then they should see the flash message "User was successfully updated"
      And they should see the following table:
        | Name          | Email                | Role   | Permission groups |
        | Albert Wesker | wesker@umbrella.corp | admin  | Unlimited access  |
        | honk          | honk@umbrella.corp   | member | -                 |
        | Ada Wong      | awong@umbrella.corp  | member | -                 |

    Scenario: Admin can't delete itself
      Given the following user:
        | Username | First name | Last name | Role  | Email               |
        | ospen    | Oswell     | Spencer   | admin | ospen@umbrella.corp |
      When they go to the provider users page
      Then the actions of row "Oswell Spencer" are:
        | Edit   |
        | Delete |
      But the actions of row "Albert Wesker" are:
        | Personal details |
