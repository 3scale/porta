Feature: Edit Integration
  In order to integrate with 3scale
  As a provider
  I want to be able to edit the integration

  Background:
    Given a provider is logged in
     And all the rolling updates features are off

  Scenario: Edit a tested integration has a link to the analytics usage
    Given the service has been successfully tested
    When I go to the service integration page
     And I follow "the analytics section"
    Then I should be on the provider stats usage page