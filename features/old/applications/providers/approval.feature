Feature: Applications management
  In order to control application creation
  As a provider
  I want to accept or reject them

  Background:
    Given a provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" uses backend v2 in his default service
    And provider "foo.3scale.localhost" has multiple applications enabled
    And provider "foo.3scale.localhost" requires cinstances to be approved before use

    And a default application plan "Basic" of provider "foo.3scale.localhost"
    And a buyer "bob" signed up to provider "foo.3scale.localhost"
    And buyer "bob" has application "MegaWidget"
    And current domain is the admin domain of provider "foo.3scale.localhost"

  @javascript @wip
  Scenario: Accept an application
    When I log in as provider "foo.3scale.localhost"
     And I go to the buyer account page for "bob"
     And I press "Accept"
    Then I should see "The application was accepted"
    # Then I should see that application "MegaWidget" is live
    # And application "MegaWidget" should be live

  @javascript @wip
  Scenario: Reject an application
    When I log in as provider "foo.3scale.localhost"
    And I go to the buyer account page for "bob"
    # Then I should see that application "MegaWidget" is suspended
    And I press "Reject"
    Then I should see "The application was rejected"

