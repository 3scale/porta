@javascript
Feature: Cross Frame Scripting Protection

    We want to ensure that any provider loggin in to the admin portal uses a browser that supports
    the X-Frame-Options header so that they are protected against Cross Frame Scripting

    Background:
      Given a provider

    Scenario: A provider tries to log in using an old browser
      Given they are not using a modern browser
      When the provider logs in
      Then the current page is the provider login page
      And they should see "The browser you are using doesn't seem to support the X-Frame-Options header. That means we can't protect you against Cross Frame Scripting and thus not guarantee the security of your session. Please upgrade your browser and sign in again."

    Scenario: A provider tries to log in using a modern browser
      Given they are using a modern browser
      When the provider logs in
      Then the current page is the provider dashboard
