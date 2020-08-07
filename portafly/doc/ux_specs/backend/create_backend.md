# Create Backend

[Back to index](../index.md)

* [Mockups](https://marvelapp.com/prototype/12844cg4)
* [Mockups JIRA ticket](https://issues.redhat.com/browse/APPDUX-343)
* [Parent JIRA ticket](https://issues.redhat.com/browse/THREESCALE-5575)

##### Title
* Create a new backend

##### Form
* Input fields
  * Name > text input [required]
    * Validation errors:
      * Required field on form submit (if left blank)
      * Name already exists on form submit
      * Name already exists on _onblur_
  * System name [required] > text input w/ placeholder and helper text
    * Inline help:
      * Label include a `pf-icon-help` icon
      * Icon toggles a popover ([PF specs](https://www.patternfly.org/v4/documentation/react/components/popover))
      * Popover includes content about
        * the need for the system name to be unique
        * an alert to users about the system name not being editable once the product is created
    * Validation errors:
      * Not valid name on form submit
      * Name already exists on form submit
      * Not valid name on _onblur_
      * Name already exists on _onblur_
  * Description > text area
    * NO validation errors
  * API private base URL > text input w/ placeholder and helper text
    * Validation errors:
      * Required field on form submit (if left blank)
      * URL scheme is not a secure protocol (https or wss)

* Buttons
  * Create button
    * Primary button style
    * Submits form
  * Cancel button
    * Link button style
    * Leads back to previous page
