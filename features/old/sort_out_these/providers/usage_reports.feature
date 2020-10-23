Feature: Usage reports
  In order to keep up-to-date with API usage
  As a provider
  I want to a usage reports emailed to me weekly or daily

  Background:
    Given all the rolling updates features are off
    Given a provider "foo.3scale.localhost"
      And admin of account "foo.3scale.localhost" has email "fake@email.com"
      And mail dispatch rule "foo.3scale.localhost/weekly_reports" is set to "true"

  Scenario: usage report sent weekly
    When weekly reports are dispatched
    Then "fake@email.com" should receive an email

  Scenario: usage report not sent daily
    And daily reports are dispatched
    Then "fake@email.com" should receive no email

