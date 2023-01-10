@javascript
Feature: Change service plan
  In order to be able to change my mind
  As a buyer
  I want to change my service plan

  Background:
    Given a provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has multiple applications enabled

      And provider "foo.3scale.localhost" has "multiple_services" visible
      And provider "foo.3scale.localhost" has "service_plans" visible
      And a default published service plan "Heavy" of service "API" of provider "foo.3scale.localhost"
      And a published service plan "Metal" of service "API" of provider "foo.3scale.localhost"

      And a service "Fancy API" of provider "foo.3scale.localhost"
      And a buyer "fan" signed up to provider "foo.3scale.localhost"
      And buyer "fan" subscribed to service plan "Heavy"

  Scenario: Direct plan change
    Given provider "foo.3scale.localhost" allows to change service plan directly

    When the current domain is foo.3scale.localhost
     And I log in as "fan" on "foo.3scale.localhost"
     And I go to the services list for buyers
     When I follow "Review/Change"
      And I follow "Metal"
      And I press "Change Plan"
     Then I should see "Plan was successfully changed to Metal."

  Scenario: Plan change by request
    Given provider "foo.3scale.localhost" allows to change service plan by request

    When the current domain is foo.3scale.localhost
     And I log in as "fan" on "foo.3scale.localhost"
     And I go to the services list for buyers

     When I follow "Review/Change"
      And I follow "Metal"
      And I press "Request Plan Change"
     Then I should see "A request to change your service plan has been sent."

  Scenario: Plan change direct if credit card present
    Given provider "foo.3scale.localhost" allows to change service plan only with credit card

    When the current domain is foo.3scale.localhost
     And I log in as "fan" on "foo.3scale.localhost"
     And I go to the services list for buyers

     When I follow "Review/Change"
      And I follow "Metal"
      And I press "Request Plan Change"
     Then I should see "A request to change your service plan has been sent."

    Given buyer "fan" has a valid credit card
     When I follow "Review/Change"
      And I follow "Metal"
      And I press "Change Plan"
     Then I should see "Plan was successfully changed to Metal."
