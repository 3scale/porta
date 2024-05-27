@javascript
Feature: Context selector

  As a user, I want to be able to switch between the different contexts of 3scale in an easy and
  quick way

  Background:
    Given a provider

  Rule: User is an admin
    Background:
      Given an admin user "Admin" of the provider
      And the user logs in

    Scenario: Admin sees all contexts
      Given the current page is the provider dashboard
      Then the current context should be "Dashboard"
      And they should be able to navigate to the following contexts:
        | Dashboard        |
        | Audience         |
        | Products         |
        | Backends         |
        | Account Settings |

  Rule: User is a member
    Background:
      Given a member user "Member" of the provider
      And the user logs in

    Scenario: Member can't see Audience, Services and Backends
      And the current page is the provider dashboard
      Then the current context should be "Dashboard"
      And they should be able to navigate to the following contexts:
        | Dashboard        |
        | Account Settings |
