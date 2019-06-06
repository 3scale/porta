@saas-only @javascript
Feature: Forum administration on the provider side
  In order to manage my forum
  As a provider
  I want to have an admin interface for it

  Background:
    And a provider "foo.example.com"
    And provider "foo.example.com" has "forum" enabled
    And an user "alice" of account "foo.example.com"
    And current domain is the admin domain of provider "foo.example.com"

  Scenario: Admin side should have admin menu
    Given I am logged in as provider "foo.example.com"
    When I navigate to the forum admin page
    Then I should see "Forum" within the main menu

    Given the forum of "foo.example.com" has category "Random stuff"
    When I navigate to the forum categories admin page
    Then I should see "Forum" within the main menu

    When I navigate to the forum my posts admin page
    Then I should see "Forum" within the main menu

  Scenario: Create topic
    When I log in as provider "foo.example.com"
    When I navigate to the forum admin page
    And I follow "New Thread"
    Then I should be on the provider side new topic page

    When I fill in "Title" with "Offtopic discussion"
    And I fill in "Body" with "Feel free to discuss anything"
    And I press "Create thread"
    Then I should be on the provider side "Offtopic discussion" topic page
    And I should see "Thread was successfully created."
    And I should see "Offtopic discussion" in a header
    And I should see post "Feel free to discuss anything"

  Scenario Outline: Admin can edit any topic
    Given the forum of "foo.example.com" has topic "<old topic>" from user "<user>" created <date>
    When I log in as provider "foo.example.com"
    And I go to the provider side "<old topic>" topic page
    And I follow "Edit topic"
    And I fill in "Title" with "<new topic>"
    And I press "Update thread"
    Then I should be on the provider side "<new topic>" topic page
    And I should see "Thread was successfully updated."
    And the forum of "foo.example.com" should have topic "<new topic>"
    But the forum of "foo.example.com" should not have topic "<old topic>"
  Examples:
    | old topic          | new topic                 | user            | date      |
    | Welcome to our frm | Welcome to out forum      | foo.example.com | today     |
    | Welcome to our frm | Welcome to out forum      | foo.example.com | yesterday |
    | Plz HELP!!!        | How to upgrade my account | alice           | today     |
    | Plz HELP!!!        | How to upgrade my account | alice           | yesterday |

  Scenario Outline: Admin can delete any topic
    Given the forum of "foo.example.com" has topic "<topic>" from user "<user>" created <date>
    When I log in as provider "foo.example.com"
    And I go to the provider side "<topic>" topic page
    And I press "Delete"
    Then I should be on the provider side forum page
    And I should see "Thread was successfully deleted."
    And the forum of "foo.example.com" should not have topic "<topic>"
  Examples:
    | topic                | user            | date      |
    | Welcome to our forum | foo.example.com | today     |
    | Welcome to our forum | foo.example.com | yesterday |
    | Plz HELP!!!          | alice           | today     |
    | Plz HELP!!!          | alice           | yesterday |

  Scenario Outline: Admin can edit any post
    Given the forum of "foo.example.com" has topic "Random chat"
    And user "<user>" posted "<old post>" <date> under topic "Random chat"
    When I log in as provider "foo.example.com"
    And I go to the provider side "Random chat" topic page
    And I follow "Edit" for post "<old post>"
    And I fill in "Body" with "<new post>"
    And I press "Update Post"
    Then I should be on the provider side "Random chat" topic page
    And I should see "Post was successfully updated."
    And topic "Random chat" should have post "<new post>"
    But topic "Random chat" should not have post "<old post>"
  Examples:
    | old post           | new post          | user            | date      |
    | Rndm stuff!        | Random stuff      | foo.example.com | today     |
    | Rndm stuff!        | Random stuff      | foo.example.com | yesterday |
    | This forum stinks! | This forum rocks! | alice           | today     |
    | This forum stinks! | This forum rocks! | alice           | yesterday |

  Scenario Outline: Admin can delete any post
    Given the forum of "foo.example.com" has topic "Random chat"
    And user "<user>" posted "<post>" <date> under topic "Random chat"
    When I log in as provider "foo.example.com"
    And I go to the provider side "Random chat" topic page
    And I press "Delete" for post "<post>"
    Then I should be on the provider side "Random chat" topic page
    And I should see "Post was successfully deleted."
    And topic "Random chat" should not have post "<post>"
  Examples:
    | post              | user            | date      |
    | Random stuff      | foo.example.com | today     |
    | Random stuff      | foo.example.com | yesterday |
    | This forum rocks! | alice           | today     |
    | This forum rocks! | alice           | yesterday |
