@ignore-backend
Feature: Applications plan
  In order to control the plan of applications
  As a provider
  I want to do stuff with the application's plans

  Background:
    Given a provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" uses backend v2 in his default service
      And provider "foo.3scale.localhost" has multiple applications enabled
      And a default application plan "Basic" of provider "foo.3scale.localhost"
      And a buyer "bob" signed up to provider "foo.3scale.localhost"
      And buyer "bob" has application "OKWidget"

    Given current domain is the admin domain of provider "foo.3scale.localhost"
      And I am logged in as provider "foo.3scale.localhost"
      And I don't care about application keys

  Scenario: Plan change does not show with only one plan
    When I navigate to the page of the partner "bob"
      And I follow the link to application "OKWidget" in the applications widget
    Then I should see the plan details widget
      But I should not see the change plan widget

  @javascript
  Scenario: Changing plan to app
    Given an application plan "Another" of provider "foo.3scale.localhost"
    When I navigate to the application "OKWidget" of the partner "bob"
    Then I should see the app plan is "Basic"

    When I change the app plan to "Another"
    Then I should see the app plan is "Another"

  Scenario: Plan can always be customized
    When I navigate to the page of the partner "bob"
      And I follow the link to application "OKWidget" in the applications widget
    Then I should be able to customize the plan

  Scenario: It shows Application expiration date when application contract is on trial
    Given the application "OKWidget" of the partner "bob" has a trial period of 10 days
    When I navigate to the application "OKWidget" of the partner "bob"
    Then I should see "trial expires in 10 days"

  @javascript
  Scenario: Customizing/Decustomizing plan of app
    Given an application plan "Another" of provider "foo.3scale.localhost"
    When I navigate to the application "OKWidget" of the partner "bob"
      And I customize the app plan
    Then I should see the app plan is customized

    When I decustomize the app plan
    Then I should see the app plan is "Basic"
