Feature: Multitenanted liquid
  In order to have multi tenant working
  as a Provider
  I want my liquids to be protected

  Background:
    Given a provider "liquid.3scale.localhost"
    And a provider "another-liquid.3scale.localhost"

  Scenario: Liquid layouts are multitenant
    Given the template of dev portal's "main_layout" of provider "liquid.3scale.localhost" is
      """
      ONE liquid provider
      {% container main %}
      """
    And the template of dev portal's "main_layout" of provider "another-liquid.3scale.localhost" is
      """
      ANOTHER liquid provider
      {% container main %}
      """

    Given the current domain is liquid.3scale.localhost
    When I go to the homepage
    Then I should see "ONE liquid provider"

    Given the current domain is another-liquid.3scale.localhost
    When I go to the homepage
    Then I should see "ANOTHER liquid provider"

  Scenario: Liquid partial inclusions are multitenant
    Given provider "liquid.3scale.localhost" has a partial "partial" with the following content:
      """
      partial ONE
      """
    And provider "another-liquid.3scale.localhost" has a partial "partial" with the following content:
      """
      partial ANOTHER
      """

    Given the template of dev portal's "main_layout" of provider "liquid.3scale.localhost" is
      """
      {% include "partial" %}
      {% container main %}
      """
    And the template of dev portal's "main_layout" of provider "another-liquid.3scale.localhost" is
      """
      {% include "partial" %}
      {% container main %}
      """

    Given the current domain is liquid.3scale.localhost
    When I go to the homepage
    Then I should see "partial ONE"

    Given the current domain is another-liquid.3scale.localhost
    When I go to the homepage
    Then I should see "partial ANOTHER"


  Scenario: Liquid partial nested inclusions are multitenant
    Given provider "liquid.3scale.localhost" has a partial "partial" with the following content:
      """
      {% include "included" %}
      """
    And provider "another-liquid.3scale.localhost" has a partial "partial" with the following content:
      """
      {% include "included" %}
      """
    Given provider "liquid.3scale.localhost" has a partial "included" with the following content:
      """
      included ONE
      """
    And provider "another-liquid.3scale.localhost" has a partial "included" with the following content:
      """
      included ANOTHER
      """

    Given the template of dev portal's "main_layout" of provider "liquid.3scale.localhost" is
      """
      {% include "partial" %}
      {% container main %}
      """
    And the template of dev portal's "main_layout" of provider "another-liquid.3scale.localhost" is
      """
      {% include "partial" %}
      {% container main %}
      """

    Given the current domain is liquid.3scale.localhost
    When I go to the homepage
    Then I should see "included ONE"

    Given the current domain is another-liquid.3scale.localhost
    When I go to the homepage
    Then I should see "included ANOTHER"
