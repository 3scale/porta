@audit @javascript
Feature: Signup
  In order to use Red Hat 3scale API management infrastructure
  As a wanna-be API provider
  I want to sign up

Background:
  Given provider "master" has "multiple_applications" denied
    And provider "master" has default service and account plan

@ignore-backend @allow-rescue
Scenario: Signup, activate, login, create sample data and let a buyer login
  Given current domain is the admin domain of provider "master"
    And master provider has the following fields defined for accounts:
    | name                 | required | read_only | hidden |
    | API_Status_3s__c     |          |           |        |
    | API_Purpose_3s__c    |          |           |        |
    | API_Type_3s__c       |          |           |        |
   When I go to the provider sign up page
   And I fill in the following:
     | Email                   | tom@monsterapi.com |
     | First name              | quentin            |
     | Organization/Group Name | foo                |
     | Password                | superSecret1234#   |
   And I press "Sign up"
   Then I should see "Hi quentin, thank you for signing up"
   And the domain of provider "foo" should be "foo.3scale.localhost"
   And the admin domain of provider "foo" should be "foo-admin.3scale.localhost"

    And provider "foo" has all the templates setup
   # --- Otherwise sample data will fail --- because it runs in different process and we cannot stub backend calls
   And the service of provider "foo" has "mandatory_app_key" set to "false"

  # --- Provider logs in ---
  When the current domain is foo-admin.3scale.localhost
  When I follow the activation link in an email sent to "tom@monsterapi.com"
   And I fill in the following:
    | Email or Username | tom@monsterapi.com |
    | Password          | superSecret1234#   |
   And I press "Sign in"
  Then I should be logged in as "admin"
  And I should be on the provider onboarding wizard page

  # TODO: since this generates request to our system, we have to fake it :/ ... trust me
  #  When I follow "Create Sample Data"
  #  Then I should see "Sample Data created"
  When provider "foo" creates sample data
  #Then provider "foo" should have sample data

  # TODO: this should be redone once we have new sample plans
  # so I'm leting it fail as a reminder
  And I go to the product's application plans admin page
  Then I should see "Unlimited"

  # --- impersonation admin user cannot log in ---
  When I log out
   And I fill in the following:
    | Email or Username | impersonationadmin |
    | Password          | wrong_pwd   |
   And I press "Sign in"
  Then I should not be logged in as "impersonationadmin"

  # --- Buyer signs up ---
  Given the current domain is foo.3scale.localhost
    And provider "foo" has site access code "foobar"
   When I go to the sign up page
    And I enter "foobar" as access code
    And I fill in the following:
     | Username                | bob                   |
     | Email                   | bob@customer.net      |
     | Organization/Group Name | bob's enterprise      |
     | Password                | superSecret1234#      |
     | Password confirmation   | superSecret1234#      |
    And I press "Sign up"
    And I wait a moment
   Then I should see "Thank you"

  # --- Buyer logs in ---
  When I follow the activation link in an email sent to "bob@customer.net"
  And I fill in the following:
    | Username or Email | bob     |
    | Password          | superSecret1234# |
  And I press "Sign in"
  Then I should see "Signed in successfully"
  Then I should be on the homepage
  # --- Sample Users logs in ---
  Then I follow "Sign Out bob"
  Then I should see "You have been logged out"
  And I follow "Login"
  And I fill in the following:
  | Username or Email |   john |
  | Password          | 123456 |
  And I press "Sign in"
  Then I should see "Signed in successfully"
  Then I should be on the homepage

# FIXME: THREESCALE-7195 this scenario is failing in CircleCI. We need to refactor it as an integration test.
@wip
Scenario: Custom portal and admin sub-domains
  Given current domain is the admin domain of provider "master"
  Given I go to the provider sign up page
  And I fill in the following:
    | Developer Portal       | hello-monster      |
  Then I should see a correct and un-editable admin portal subdomain
