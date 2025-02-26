Feature: Dev portal backwards compatibility

  As a long time 3scale user, I don't want any new updates in 3scale to break my developer portal.

  Background:
    Given a provider
    And the current domain is "foo.3scale.localhost"

  Scenario: Essential assets
    Given the provider has main layout with:
      """
      <html>
        <head>
          {% essential_assets %}
        </head>
        <body>
          Good news everyone!
        </body>
      </html>
      """
    And the cms page "/" has main layout
    When they go to the homepage
    Then they should see "Good news everyone!"
