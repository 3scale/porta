@javascript
Feature: Audience's applications list page

  Background:
    Given a provider
    And a product "My API"
    And another product "Another API"
    And the following application plans:
      | Product     | Name      | Cost per month | Setup fee |
      | My API      | Cheap     | 0              | 0         |
      | My API      | Expensive | 100            | 10        |
      | Another API | Bronze    |                | 5         |
    And a buyer "Bob"
    And buyer "Bob" has email "buyer@example.com"
    And a buyer "Jane"
    And the following applications:
      | Buyer | Name            | Plan      | Created at        |
      | Bob   | Another API App | Bronze    | December 10, 2023 |
      | Bob   | Bob's App       | Cheap     | December 11, 2023 |
      | Jane  | Jane's Lite App | Cheap     | December 12, 2023 |
      | Jane  | Jane's Full App | Expensive | December 13, 2023 |
    And no emails have been sent
    And the provider logs in
    And they go to the admin portal applications page

  Scenario: Navigation
    Given they go to the provider dashboard
    When they follow "4 Applications" within the audience dashboard widget
    Then the current page is the admin portal applications page

  Scenario: Searching by multiple criteria
    When they search for:
      | Name | Plan  | State |
      | Bob  | Cheap | live  |
    Then the table looks like:
      | Name      | Account |
      | Bob's App | Bob     |

  Scenario: Searching by plan
    Given they go to the admin portal applications page with 1 record per page
    And they should see 4 pages
    When they search for:
      | Plan  |
      | Cheap |
    And follow "Account" within table header
    Then the table looks like:
      | Account |
      | Bob     |
      | Jane    |

  Scenario Outline: Ordering
    When they follow "<order by>" within table header
    Then the table should be sorted by "<order by>"

    Examples:
      | order by   |
      | Name       |
      | Account    |
      | Plan       |
      | State      |
      | Created on |

  Scenario: Available bulk operations
    When item "Bob's App" is selected
    Then the following bulk operations are available:
      | Send email              |
      | Change application plan |
      | Change state            |

  Scenario: Bulk operations card shows when an items are selected
    When item "Bob's App" is selected
    And item "Jane's Lite App" is selected
    Then the bulk operations are visible
    And should see "You have selected 2 applications and you can make following operations with them:"
    But item "Bob's App" is unselected
    And item "Jane's Lite App" is unselected
    Then the bulk operations are not visible

  Scenario: Select all items in the table
    When they select all items in the table
    Then the bulk operations are visible
    When they unselect all items in the table
    Then the bulk operations are not visible

  Scenario: Send an email without subject
    Given item "Bob's App" is selected
    When they select bulk action "Send email"
    And the modal is submitted with:
      | Subject |                  |
      | Body    | This is the body |
    Then the buyer has received no emails

  Scenario: Send an email without body
    Given item "Bob's App" is selected
    When they select bulk action "Send email"
    And the modal is submitted with:
      | Subject | This is a subject |
      | Body    |                   |
    Then the buyer has received no emails

  Scenario: Send email in bulk
    Given the buyer has received no emails
    And item "Bob's App" is selected
    And item "Jane's Lite App" is selected
    And item "Jane's Full App" is selected
    When they select bulk action "Send email"
    And the modal is submitted with:
      | Subject | This is a subject |
      | Body    | This is the body  |
    And confirm the dialog
    Then they should see the flash message "Successfully sent 3 emails."
    Then buyer "Bob" has received 1 email
    And buyer "Jane" has received 2 email

  Scenario: Change application plan in bulk
    Given the table has the following rows:
      | Name            | Plan      |
      | Jane's Full App | Expensive |
      | Jane's Lite App | Cheap     |
      | Bob's App       | Cheap     |
    And item "Bob's App" is selected
    And item "Jane's Lite App" is selected
    When they select bulk action "Change application plan"
    And the modal is submitted with:
      | Plan | Expensive |
    And confirm the dialog
    Then they should see the flash message "Successfully changed the plan of 2 applications"
    And the table has the following rows:
      | Name            | Plan      |
      | Jane's Full App | Expensive |
      | Jane's Lite App | Expensive |
      | Bob's App       | Expensive |

  Scenario: Can't change the plan of applications from different services
    Given item "Bob's App" is selected
    And item "Another API App" is selected
    When they select bulk action "Change application plan"
    Then should not see "Change plan" within the modal
    And should see "You have selected applications from different services"

  Scenario: Change state in bulk
    Given the table has the following rows:
      | Name            | State |
      | Jane's Full App | live  |
      | Bob's App       | live  |
    And item "Bob's App" is selected
    And item "Jane's Full App" is selected
    When they select bulk action "Change state"
    And the modal is submitted with:
      | Action | Suspend |
    And confirm the dialog
    Then they should see the flash message "Successfully changed the state of 2 applications"
    And the table has the following rows:
      | Name            | State     |
      | Jane's Full App | suspended |
      | Bob's App       | suspended |

  Scenario: Sending email throws an error
    Given the email will fail when sent
    And item "Bob's App" is selected
    When they select bulk action "Send email"
    And the modal is submitted with:
      | Subject | Warning!!      |
      | Body    | This will fail |
    And confirm the dialog
    Then the bulk operation has failed for "Bob"
    And the buyer has received no emails

  Scenario: Changing state throws an error
    Given the application will return an error when suspended
    When item "Bob's App" is selected
    And select bulk action "Change state"
    And the modal is submitted with:
      | Action | Suspend |
    And confirm the dialog
    Then the bulk operation has failed for "Bob's App"
    And the table has the following row:
      | Name      | State |
      | Bob's App | live  |

  Scenario: Changing app plan throws an error
    Given the application will return an error when changing its plan
    And item "Bob's App" is selected
    When they select bulk action "Change application plan"
    And the modal is submitted with:
      | Plan | Expensive |
    And confirm the dialog
    Then the bulk operation has failed for "Bob's App"
    And the table has the following row:
      | Name      | Plan  |
      | Bob's App | Cheap |
