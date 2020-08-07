# Edit Backend

[Back to index](../index.md)

* [Mockups](https://marvelapp.com/prototype/12844cg4/screen/71559182)
* [Mockups JIRA ticket](https://issues.redhat.com/browse/APPDUX-348)
* [Parent JIRA ticket](https://issues.redhat.com/browse/THREESCALE-5577)

##### Form
* Input fields
  * Name > text input [required]
    * Validation errors:
      * Required field on form submit (if left blank)
      * Name already exists on form submit
      * Name already exists on _onblur_

  * System name > text input [required] [disabled]
    * helper text :
        * System name cannot be changed
    * NO validation errors

  * Description > text area
    * NO validation errors

  * API private base URL > text input [required]
    * Validation errors :
      * Required field on form submit (if left blank)
      * URL scheme is not a secure protocol (https or wss)
* Buttons
  * Save button
    * Primary button style
    * Submits form
  * Cancel button
    * Link button style
    * Leads back to previous page
