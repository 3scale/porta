# Edit Product

[Back to index](../index.md)

* [Mockups](https://marvelapp.com/prototype/ee82j74/screen/70939421)
* [Mockups JIRA ticket](https://issues.redhat.com/browse/THREESCALE-4523)
* [Parent JIRA ticket](https://issues.redhat.com/browse/THREESCALE-4198)

##### Form
* Input fields
  * Name > text input [required]
    * Validation errors ([specs](../../global_components/alerts.md)):
      * Required field on form submit (if left blank)
    * Validation alerts ([specs](../../global_components/alerts.md)):
      * Name is already in use exists on form submit
      * Name is already in use on _onblur_
  * System name > text input w/ placeholder and helper text
  * System name > text input [disabled]
    * Inline help:
      * Label include a `pf-icon-help` icon
      * Icon toggles a popover ([PF specs](https://www.patternfly.org/v4/documentation/react/components/popover))
      * Popover includes content about the reasons why a System name cannot be changed
    * NO validation errors
  * Description > text area
    * NO validation errors
* Buttons
  * Save button
    * Primary button style
    * Submits form
  * Cancel button
    * Link button style
    * Leads back to previous page
