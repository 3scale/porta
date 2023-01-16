Feature: Render liquid templates from database
  In order to customize the builtin pages
  as a Provider
  I want to edit the templates via CMS and see the results

  Background:
    Given a provider "foo.3scale.localhost" with default plans
    And provider "foo.3scale.localhost" has all the templates setup
    And provider "foo.3scale.localhost" has "multiple_users" switch visible

  @search
  Scenario Outline: Override pages
    Given provider "foo.3scale.localhost" has "account_plans" visible
    And provider "foo.3scale.localhost" has "finance" switch visible
    And provider "foo.3scale.localhost" is charging its buyers with braintree
    And a published account plan "Basic" of provider "foo.3scale.localhost"
    And a application plan "Pro" of provider "foo.3scale.localhost"
    And a buyer "bob" signed up to application plan "Pro"
    And provider "foo.3scale.localhost" has "multiple_services" visible
    And provider "foo.3scale.localhost" has "service_plans" visible

    When I log in as "bob" on foo.3scale.localhost
    And I go to the <path> page
    Then I should see "<original_content>"
    When builtin page "<system_name>" of provider "foo.3scale.localhost" has content "EDITED <system_name>"
    And I go to the <path> page
    Then I should see "EDITED <system_name>"

   Examples:
      | system_name                    | path                     | original_content          |
      | services/index                 | services list for buyers | Description Plan          |
      | user/show                      | personal details         | Username                  |
      | messages/inbox/index           | inbox                    | Inbox                     |
      | messages/inbox/show            | inbox show               |                           |
      | messages/outbox/index          | outbox                   | Sent Messages             |
      | messages/outbox/show           | outbox show              |                           |
      | messages/outbox/new            | compose                  | Compose                   |
      | messages/trash/index           | trash                    | Trash                     |
      | messages/trash/show            | trash show               |                           |
      | account/show                   | account                  | Account Details           |
      | account/edit                   | account edit             | Account Details           |
      | invitations/index              | sent invitations         | Invitations               |
      | invitations/new                | new invitation           | Invitation                |
      | account_plans/index            | account plans            | You are currently on plan |
      | accounts/payment_gateways/show | credit card details      | Entering Credit Card      |
      | stats/index                    | buyer stats              | Graphs                    |
      | search/index                   | search                   | Search                    |
      | dashboards/show                | dashboard                | Credentials               |


  Scenario Outline: Override public pages
   Given a buyer "bob" signed up to provider "foo.3scale.localhost"
   And I log in as "bob" on foo.3scale.localhost
   When I go to the <page> page
   Then I should see markup matching '<original>'
   When builtin partial "<system_name>" of provider "foo.3scale.localhost" has content "PARTIAL <system_name> EDITED"
   And I go to the <page> page
   Then I should see "PARTIAL <system_name> EDITED"
   And I should not see markup matching '<original>'

   Examples:
      | system_name | page    | original                           |
      | submenu     | account | li.active > a:contains("Settings") |
      | users_menu  | users   | ul.nav.nav-tabs                    |

  Scenario Outline: As logged out user
    When the current domain is foo.3scale.localhost
    When I go to the <path> page
    Then I should see "<original>"
    And builtin page "<system_name>" of provider "foo.3scale.localhost" has content "EDITED <system_name>"
    And I go to the <path> page
    Then I should see "EDITED <system_name>"

   Examples:
      | system_name  | path            | original        |
      | password/new | forgot password | Forgot password |
      | login/new    | login           | Sign in         |

  Scenario: Signup
    When the current domain is "foo.3scale.localhost"
    And I go to the signup page
    Then I should see "Sign up"

    When builtin page "signup/show" of provider "foo.3scale.localhost" has content "EDITED Signup"
     And I go to the signup page
    Then I should see "EDITED Signup"

  # Extra because of those 3 steps to be able to reach the app
  Scenario: New Application
   Given provider "foo.3scale.localhost" has "multiple_applications" visible
    And a service plan "Gold" of provider "foo.3scale.localhost"
    And a buyer "john" signed up to service plan "Gold"

    When I log in as "john" on foo.3scale.localhost
     And I go to the new application page
    Then I should see "New Application"

    When builtin page "applications/new" of provider "foo.3scale.localhost" has content "EDITED app page"
     And I go to the new application page
    Then I should see "EDITED app page"

  # Extra because the user is not logged in
  Scenario: Login page
    When the current domain is foo.3scale.localhost
     And I go to the login page
    Then I should see "Username or Email"

    When builtin page "login/new" of provider "foo.3scale.localhost" has content "EDITED PAGE"
    And I go to the login page
    Then I should see "EDITED PAGE"
    And I should not see "Username or Email"
