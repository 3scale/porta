Feature: Accounts plan
  In order to control the plan of accounts
  As a provider
  I want to do stuff with the account's plans

  Background:
    Given a provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" uses backend v2 in his default service
      And provider "foo.3scale.localhost" has multiple applications enabled
      And provider "foo.3scale.localhost" has "account_plans" visible

    Given a default application plan "Basic" of provider "foo.3scale.localhost"
    Given a buyer "bob" signed up to provider "foo.3scale.localhost"

    Given current domain is the admin domain of provider "foo.3scale.localhost"
      And I am logged in as provider "foo.3scale.localhost"


  @ignore-backend @javascript
  Scenario: Customizing/Decustomizing account plan
     When I go to the buyer account page for "bob"
      And I customize the account plan
      And I go to the buyer account page for "bob"
    Then I should see the account plan is customized

    Given a buyer "tom" signed up to provider "foo.3scale.localhost"
     When I go to the buyer account page for "tom"
      And I customize the account plan
      #And I fill in "Name" with "unique customized name"
      #And I fill in "System name" with "unique_customized_name"
      #And I press "Create Account plan"
     Then I should see the account plan is customized

    When I go to the buyer account page for "bob"
    When I decustomize the account plan
    Then I should not see the account plan is customized

