# Create Product

[Back to index](../index.md)

* [Mockups](https://marvelapp.com/prototype/ee82j74/screen/70939425)
* [Mockups JIRA ticket](https://issues.redhat.com/browse/THREESCALE-5548)
* [Parent JIRA ticket](https://issues.redhat.com/browse/THREESCALE-5547)

##### Form
* Input fields
  * Name [required] > text input
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
* Buttons
  * Create button
    * Primary button style
    * Submits form
  * Cancel button
    * Link button style
    * Leads back to previous page
