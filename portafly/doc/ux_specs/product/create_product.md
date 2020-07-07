# Create Product

[Back to index](../../index.md)

* [Mockups](https://marvelapp.com/prototype/ee82j74/screen/70939425)
* [Mockups JIRA ticket](https://issues.redhat.com/browse/THREESCALE-5548)
* [Parent JIRA ticket](https://issues.redhat.com/browse/THREESCALE-5547)

##### Form
* Input fields
  * Name > text input [required]
    * Validation errors:
      * Required field on form submit (if left blank)
      * Name already exists on _onblur_
  * System name > text input w/ helper text
    * Validation errors:
      * Not valid name on _onblur_
      * Name already exists on _onblur_
  * Description > text area
    * NO validation errors
* Buttons
  * Create button
    * Primary button style
    * Submits form
  * Cancel button
    * Link button style
    * Leads back to previous page
