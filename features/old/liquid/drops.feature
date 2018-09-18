Feature: Liquid drops
  In order to allow providers to customize page
  We need Liquid Drops to provide data needed for customization

  Background:
    Given a provider "foo.example.com"
    Given provider "foo.example.com" has Browser CMS activated
      And the current domain is foo.example.com

  Scenario: MenuDrop
    Given a buyer "bob" of provider "foo.example.com"
      And I am logged in as "bob"

    When provider "foo.example.com" has following template
      """
      <title>{{ _menu.active_menu | capitalize }}{% if _menu.active_submenu %} | {{ _menu.active_submenu | capitalize }}{% endif %}</title>
      {% content %}
      """
    Then page "the homepage" should contain
      """
      <title>Portal</title>
      """
    And page "the account page" should contain
      """
      <title>Account | Overview</title>
      """
