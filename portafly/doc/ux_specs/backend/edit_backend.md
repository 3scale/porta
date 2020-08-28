# Edit Backend

[Back to index](../index.md)

* [Mockups](https://marvelapp.com/prototype/12844cg4/screen/71559181)
* [Mockups JIRA ticket](https://issues.redhat.com/browse/APPDUX-348)
* [Parent JIRA ticket](https://issues.redhat.com/browse/THREESCALE-5577)

##### Form
* Input fields
  * Name [required] > text input
    * Validation errors ([specs](../../global_components/alerts.md)):
      * Required field on form submit (if left blank)
    * Validation alerts ([specs](../../global_components/alerts.md)):
    <!-- * Name is already in use on form submit -->
      * Name is already in use recommendation on _onblur_
  * System name > text input [disabled]
      * Inline help:
        * Label include a `pf-icon-help` icon
        * Icon toggles a popover ([PF specs](https://www.patternfly.org/v4/documentation/react/components/popover))
        * Popover includes content about a system name cannot be edited once the product is created
      * No validation errors
  * Description > text area
    * No validation errors
  * API private base URL [required] > text input 
    * Validation errors :
      * Required field on form submit (if left blank)
      * URL scheme is not a secure protocol on form submit (https or wss)
* Buttons
  * Save button
    * Primary button style
    * Submits form
  * Cancel button
    * Link button style
    * Leads back to previous page
