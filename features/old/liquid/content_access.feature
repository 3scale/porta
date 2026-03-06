Feature: Content access in liquid
  In order to control access to content in the site
  As a provider
  I want to be able to hide or show content based on users permissions

  Background:
    Given a provider "foo.3scale.localhost"
    And the provider has cms page "/protected" with:
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
    And the current domain is foo.3scale.localhost


  Scenario: Not logged in user has access denied to protected content in page
    When they request the url "/protected"
    Then I should see "Protected Content Access DENIED"

  Scenario: Buyer without access cannot see protected content
    Given a buyer "buyer" signed up to provider "foo.3scale.localhost"
      And I am logged in as "buyer"
    When they request the url "/protected"
    Then I should see "Protected Content Access DENIED"

  Scenario: Buyer with access granted can see protected content
    Given a buyer "buyer" signed up to provider "foo.3scale.localhost"
    And the provider has the following section:
      | Title             | Public |
      | protected-section | False  |
    And the buyer has access to section "protected-section" of the provider
      And I am logged in as "buyer"
    When they request the url "/protected"
    Then I should see "Protected Content Access GRANTED"
