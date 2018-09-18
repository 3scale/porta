Feature: CMS Toolbar
  In order to easily edit partials and templates on the buyer side
  User can switch to CMS Admin mode where he can switch Draft/Published content and see
  all rendered templates, partials, pages and layouts.

  #
  # Because the original page is embedded in an iframe, the
  # functionality is now covered in
  #
  # test/integration/cms/toolbar_test.rb
  #

  # Background:
  #   Given a provider "foo.example.com" with default plans
  #   And provider "foo.example.com" has all the templates setup
  #   And the current provider is foo.example.com
  #   And the current domain is foo.example.com
  #   And I am in CMS Admin mode

  # Scenario: Edit Application page
  #   Given a buyer "bob" signed up to application plan "Default"
  #   And I am logged in as "bob"
  #   And I visit "/admin/access_details"
  #   And I follow "Edit" within page content
  #   Then I should see CMS Toolbar
  #   And I should see "Draft"
  #   And I should see "Published"
