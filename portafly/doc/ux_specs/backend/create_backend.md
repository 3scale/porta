# Create Backend

[Back to index](../index.md)

* [Mockups](https://marvelapp.com/prototype/12844cg4/screen/71559193)
* [Mockups JIRA ticket](https://issues.redhat.com/browse/APPDUX-343)
* [Parent JIRA ticket](https://issues.redhat.com/browse/THREESCALE-5575)

##### Form
* Input fields
  * Name [required] > text input
    * Validation errors ([specs](../../global_components/alerts.md)):
      * Required field on form submit (if left blank)
    * Validation alerts ([specs](../../global_components/alerts.md)):
       <!-- * Name is already in use on form submit -->
       * Name is already in use recommendation on _onblur_
  * System name [required] > text input with placeholder and helper text
    * Inline help:
      * Label include a `pf-icon-help` icon
      * Icon toggles a popover ([PF specs](https://www.patternfly.org/v4/documentation/react/components/popover))
      * Popover includes content about
        * the need for the system name to be unique
        * an alert to users about the system name not being editable once the product is created
    * Validation errors:
      * Not a valid name on form submit
      * Name already exists on form submit
      * Not a valid name on _onblur_
      * Name already exists on _onblur_
  * Description > text area
    * NO validation errors
  * API private base URL [required] > text input with placeholder and helper text
    * Validation errors:
      * Required field on form submit (if left blank)
      * URL scheme is not a secure protocol on form submit (https or wss)

* Buttons
  * Create button
    * Primary button style
    * Submits form
  * Cancel button
    * Link button style
    * Leads back to previous page
