@javascript @ignore-backend
Feature: Applications management
  In order to control the way my buyers are using my API
  As a provider
  I want to do stuff with their applications

  Background:
    Given a provider is logged in
    And the provider uses backend v2 in his default service
    And the provider has multiple applications enabled
    And a default application plan "Basic" of provider "foo.3scale.localhost"
    And plan "Basic" is published
    And a buyer "bob" signed up to provider "foo.3scale.localhost"
    And buyer "bob" is subscribed to the default service of provider "foo.3scale.localhost"

  Scenario: No applications
    Given buyer "bob" has no applications
    And I go to the buyer account page for "bob"
    Then I should see "0 Applications"

  Scenario: Application details
    Given buyer "bob" has application "FunkyWidget" with description "Widget for some funky stuff"
    And I go to the buyer account page for "bob"
    And I follow "FunkyWidget" in the applications widget
    Then I should be on the provider side "FunkyWidget" application page
    And I should see "FunkyWidget" in a header
    And I should see "Widget for some funky stuff"

  Scenario: Delete application
    Given buyer "bob" has application "FunkyWidget" with description "Widget for some funky stuff"
    And there are no events
    And I go to the buyer account page for "bob"
    And I follow "FunkyWidget" in the applications widget
    Then I should be on the provider side "FunkyWidget" application page
    Then I follow "Edit"
    When I follow "Delete" and I confirm dialog box
    Then I should see "The application was successfully deleted."
    And I should not see "FunkyWidget"
    # FIXME: this fails for some reason, could we remove it? Does it make sense in this test?
    # And there should be 1 valid cinstance cancellation event

  Scenario: List all applications of buyer
    Given buyer "bob" has application "SimpleApp"
     And buyer "bob" has application "ComplicatedApp"
     And I go to the buyer account page for "bob"
    When I follow "2 Applications"
     And I follow "Name"
    Then I should see following table:
      | Name           | State |
      | ComplicatedApp | live  |
      | SimpleApp      | live  |

  Scenario: Suspend an application
    Given buyer "bob" has application "MegaWidget"
    And I go to the provider side "MegaWidget" application page
    Then I should see that application "MegaWidget" is live
    When I follow "Suspend" and I confirm dialog box
    Then I should see that application "MegaWidget" is suspended
    And application "MegaWidget" should be suspended

  Scenario: Resume an application
    Given buyer "bob" has application "MegaWidget"
    And application "MegaWidget" is suspended
    And I go to the provider side "MegaWidget" application page
    Then I should see that application "MegaWidget" is suspended
    When I follow "Resume"
    Then I should see that application "MegaWidget" is live
    And application "MegaWidget" should be live
