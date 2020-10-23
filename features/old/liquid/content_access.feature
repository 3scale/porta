Feature: Content access in liquid
  In order to control access to content in the site
  As a provider
  I want to be able to hide or show content based on users permissions

  Background:
    Given a provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has multiple applications enabled
    Given provider "foo.3scale.localhost" has Browser CMS activated
      And the template "main_layout" of provider "foo.3scale.localhost" is
        """
        {% if current_user.sections contains "/protected-section" %}
          Protected Content Access GRANTED
        {% else %}
          Protected Content Access DENIED
        {% endif %}

        {% content %}

      #ignore, this is here to make all work
      {% if flash.messages.size > 0 %}
        <div>
          {% for message in flash.messages %}
            <div class="navbar navbar-fixed-top navbar-default alert-{{ message.type }}" data-dismiss="alert" id="flash-messages">
              <div class="container">
                <div id="flash">
                  <button type="button" class="close"  aria-hidden="true">&times;</button>
                  {{ message.text }}
                </div>
              </div>
            </div>
          {% endfor %}
        </div>
      {% endif %}
    """
    And the current domain is "foo.3scale.localhost"


  Scenario: Not logged in user has access denied to protected content in page
    When I go to the homepage
    Then I should see "Protected Content Access DENIED"

  Scenario: Buyer without access cannot see protected content
    Given a buyer "buyer" signed up to provider "foo.3scale.localhost"
      And I am logged in as "buyer"
    When I go to the homepage
    Then I should see "Protected Content Access DENIED"

  Scenario: Buyer with access granted can see protected content
      And provider "foo.3scale.localhost" has a private section "protected-section"
    Given a buyer "buyer" signed up to provider "foo.3scale.localhost"
      And the buyer "buyer" has access to the section "protected-section" of provider "foo.3scale.localhost"
      And I am logged in as "buyer"
    When I go to the homepage
    Then I should see "Protected Content Access GRANTED"
