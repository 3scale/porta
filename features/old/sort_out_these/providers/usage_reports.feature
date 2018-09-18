Feature: Usage reports
  In order to keep up-to-date with API usage
  As a provider
  I want to a usage reports emailed to me weekly or daily

  Background:
    Given all the rolling updates features are off
    Given a provider "foo.example.com"
      And admin of account "foo.example.com" has email "fake@email.com"
      And mail dispatch rule "foo.example.com/weekly_reports" is set to "true"

  Scenario: usage report sent weekly
    When weekly reports are dispatched
    Then "fake@email.com" should receive an email

  Scenario: usage report not sent daily
    And daily reports are dispatched
    Then "fake@email.com" should receive no email

