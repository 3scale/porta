@javascript
Feature: Provider accounts management
  As a master I to want to manage my provider accounts

  Background:
    Given a master admin with extra fields is logged in

  Scenario: Create a provider account with valid params
    When new form to create a tenant is filled and submitted
    Then new tenant should be created

  Scenario: Create a provider account with invalid params
    When new form to create a tenant is filled and submitted with invalid data
    Then new tenant should be not created