Feature: Multitenanted liquid
  In order to have multi tenant working
  as a Provider
  I want my liquids to be protected

  Background:
    Given a provider "liquid.example.com"
      And provider "liquid.example.com" has Browser CMS activated
    Given a provider "another-liquid.example.com"
      And provider "another-liquid.example.com" has Browser CMS activated

  Scenario: Liquid layouts are multitenant
    Given the template "main_layout" of provider "liquid.example.com" is
      """
      ONE liquid provider
      {% container main %}
      """
    And the template "main_layout" of provider "another-liquid.example.com" is
      """
      ANOTHER liquid provider
      {% container main %}
      """

    Given the current domain is liquid.example.com
    When I go to the homepage
    Then I should see "ONE liquid provider"

    Given the current domain is another-liquid.example.com
    When I go to the homepage
    Then I should see "ANOTHER liquid provider"

  Scenario: Liquid partial inclusions are multitenant
    Given the partial "partial" of provider "liquid.example.com" is
      """
      partial ONE
      """
    And the partial "partial" of provider "another-liquid.example.com" is
      """
      partial ANOTHER
      """

    Given the template "main_layout" of provider "liquid.example.com" is
      """
      {% include "partial" %}
      {% container main %}
      """
    And the template "main_layout" of provider "another-liquid.example.com" is
      """
      {% include "partial" %}
      {% container main %}
      """

    Given the current domain is liquid.example.com
    When I go to the homepage
    Then I should see "partial ONE"

    Given the current domain is another-liquid.example.com
    When I go to the homepage
    Then I should see "partial ANOTHER"


  Scenario: Liquid partial nested inclusions are multitenant
    Given the partial "partial" of provider "liquid.example.com" is
      """
      {% include "included" %}
      """
    And the partial "partial" of provider "another-liquid.example.com" is
      """
      {% include "included" %}
      """
    Given the partial "included" of provider "liquid.example.com" is
      """
      included ONE
      """
    And the partial "included" of provider "another-liquid.example.com" is
      """
      included ANOTHER
      """

    Given the template "main_layout" of provider "liquid.example.com" is
      """
      {% include "partial" %}
      {% container main %}
      """
    And the template "main_layout" of provider "another-liquid.example.com" is
      """
      {% include "partial" %}
      {% container main %}
      """

    Given the current domain is liquid.example.com
    When I go to the homepage
    Then I should see "included ONE"

    Given the current domain is another-liquid.example.com
    When I go to the homepage
    Then I should see "included ANOTHER"
