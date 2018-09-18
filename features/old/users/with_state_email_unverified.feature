Feature: Users enter email unverified state
  In order to keep the users with email unverified in control
  The system must provide a way of handle them

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" has multiple applications enabled
    Given a buyer "alice" signed up to provider "foo.example.com"


  Scenario: User in unverified_email state can login
    Given user "alice" is email unverified
    When I log in as "alice" on foo.example.com
    Then I should be logged in as "alice"

  @wip
  Scenario: User in unverified_email state sees notice in personal details page
    Given user "alice" is email unverified
    When I log in as "alice" on foo.example.com
      And I navigate to my personal details page
    Then I should see the notice to validate my email

  @wip
  Scenario: When user edits his email he should verify its email
    Given user "alice" is active
    When I log in as "alice" on foo.example.com
      And I navigate to my personal details page

    When I fill in my email with "newmail@example.com"
      And I commit the changes to my personal details
    Then "newmail@example.com" should receive an email to verify email address

    When I navigate to my personal details page
    Then I should see the notice to validate my email

  @wip
  Scenario: Email_unverified user receives verify email everytime he edits his details
    Given user "alice" is email unverified
    When I log in as "alice" on foo.example.com
      And I navigate to my personal details page

    When I change my name without changing the email
      And I commit the changes to my personal details
    Then user "alice" should receive an email to verify email address

  @wip
  Scenario: User verify his email when logged in
    Given user "alice" is active
    When I log in as "alice" on foo.example.com
      And I change my email to "newmail@example.com"
    Then "newmail@example.com" should receive an email to verify email address

    When I follow the link to verify email in the email to verify email address
    Then I should see the notice that the email is verified
      And user "alice" should be active

  @wip
  Scenario: User verify his email when not logged in
    Given user "alice" is active
    When I log in as "alice" on foo.example.com
      And I change my email to "newmail@example.com"
    Then "newmail@example.com" should receive an email to verify email address

    When I log out
      And I follow the link to verify email in the email to verify email address
    Then I should see the notice that the email is verified
      And user "alice" should be active

  @wip
  Scenario: User restart email verification process
    Given user "alice" is email unverified
    When I log in as "alice" on foo.example.com
      And I navigate to my personal details page
      And I resend the email verification
    Then user "alice" should receive an email to verify email address
