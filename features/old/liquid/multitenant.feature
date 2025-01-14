Feature: Multitenanted liquid
  In order to have multi tenant working
  as a Provider
  I want my liquids to be protected

  Background:
    Given a provider "liquid.3scale.localhost"
    And a provider "another-liquid.3scale.localhost"

  Scenario: Liquid layouts are multitenant
    Given the template "main_layout" of provider "liquid.3scale.localhost" is
      """
      ONE liquid provider
      {% container main %}
      """
    And the template "main_layout" of provider "another-liquid.3scale.localhost" is
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
    Given the partial "partial" of provider "liquid.3scale.localhost" is
      """
      partial ONE
      """
    And the partial "partial" of provider "another-liquid.3scale.localhost" is
      """
      partial ANOTHER
      """

    Given the template "main_layout" of provider "liquid.3scale.localhost" is
      """
      {% include "partial" %}
      {% container main %}
      """
    And the template "main_layout" of provider "another-liquid.3scale.localhost" is
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
    Given the partial "partial" of provider "liquid.3scale.localhost" is
      """
      {% include "included" %}
      """
    And the partial "partial" of provider "another-liquid.3scale.localhost" is
      """
      {% include "included" %}
      """
    Given the partial "included" of provider "liquid.3scale.localhost" is
      """
      included ONE
      """
    And the partial "included" of provider "another-liquid.3scale.localhost" is
      """
      included ANOTHER
      """

    Given the template "main_layout" of provider "liquid.3scale.localhost" is
      """
      {% include "partial" %}
      {% container main %}
      """
    And the template "main_layout" of provider "another-liquid.3scale.localhost" is
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
