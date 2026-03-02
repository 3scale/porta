Feature: Markdown/Textile Handlers
  In order to simplify writing content
  As a provider
  I want to write markdown/textile format

  Scenario:
    Given a provider "foo.3scale.localhost"
    And the current domain is "foo.3scale.localhost"
    And the provider has the following page:
      | Title            | System name | path  | Handler  | Published          |
      | My Markdown Page | my-page     | /page | markdown | # Markdown content |
    When I visit "/page"
    Then they should not see "# Markdown content"
    But they should see "Markdown content"
