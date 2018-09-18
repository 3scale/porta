Feature: Content for and content of


  Scenario: Store something by tag and print it by drop
    Given a provider "foo.example.com"
    And the current provider is foo.example.com
    And the current domain is foo.example.com
    And the provider has cms page "/some-page" with:
    """
      {% content_for something %}
        <something></something>
      {% endcontent_for %}
      <content></content>
    """
    And the provider has main layout with:
    """
    <html>
      <head>
        {{ content_of.something | html_safe }}
      </head>
      <body>
        {% content %}
      </body>
    </html>
    """
    And the cms page "/some-page" has main layout

    And I visit "/some-page"
    Then the html body should contain "<content></content>"
    And the html head should contain "<something></something>"