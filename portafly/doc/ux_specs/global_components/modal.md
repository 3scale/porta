# Modals UX/UI specs

[Back to index](../index.md)

* [PatternFly Modal dialog design guidelines](https://www.patternfly.org/v4/design-guidelines/usage-and-behavior/modal)
* [PatternFly-react Modal docs](https://www.patternfly.org/v4/documentation/react/components/modal)

### Global modal specs
* Modal dialogs are placed in the exact center of the page.
* Modal dialogs feature an "X" icon in the top right corner. Clicking the icon will dismiss the modal.
* Typing "Esc" on a keyboard will dismiss the modal.
* When some content is added to an input field (if any) and user tries to dismiss the modal (with whatever method available), a native browser alert is triggered informing user about the eventuality of content loss, and asking to confirm dismissing the modal.


### _'Change plan for selected items'_ modal
* Form ([PF specs](https://www.patternfly.org/v4/documentation/react/components/form))
  * List of selected items > unordered list ([PF specs](https://www.patternfly.org/v4/documentation/react/components/list))
    * Items are displayed in alphabetical order
    * When the list of selected items is bigger than 5 items, only the first 5 will be displayed
      * also, a link button will be displayed at the bottom of the list to trigger display of the remaining items
    * When the full list is displayed, the height of the container will be fixed and the content will be scrollable so that the entire dialog can still be seen above the fold
  * Select plan field > dropdown ([PF specs](https://www.patternfly.org/v4/documentation/react/components/dropdown))
    * mandatory field
    * dropdown menu content is specified in the relative page UX specification file
  * Buttons:
    * Submit button [Disabled state until all conditions required to submit the form are met]
    * Cancel button [Always enabled]
      * Dismisses modal


### _'Change state for selected items'_ modal
* Form ([PF specs](https://www.patternfly.org/v4/documentation/react/components/form))
  * List of selected items > unordered list ([PF specs](https://www.patternfly.org/v4/documentation/react/components/list))
    * Items are displayed in alphabetical order
    * When the list of selected items is bigger than 5 items, only the first 5 will be displayed
      * also, a button will be displayed at the bottom of the list to trigger display of the remaining items
    * When the full list is displayed, the height of the container will be fixed and the content will be scrollable so that the entire dialog can still be seen above the fold
  * Select state field > dropdown ([PF specs](https://www.patternfly.org/v4/documentation/react/components/dropdown))
    * mandatory field
    * dropdown menu content is specified in the relative page UX specification file
  * Buttons:
    * Submit button [Disabled state until all conditions required to submit the form are met]
    * Cancel button [Always enabled]
      * Dismisses modal


<!-- ### _'Send email to selected items'_ modal
      * Form ([PF specs](https://www.patternfly.org/v4/documentation/react/components/form))
        * List of selected items > unordered list ([PF specs](https://www.patternfly.org/v4/documentation/react/components/list))
          * Items are displayed in alphabetical order
          * When the list of selected items is bigger than 5 items, only the first 5 will be displayed
            * also, a button will be displayed at the bottom of the list to trigger display of the remaining items
          * When the full list is displayed, the height of the container will be fixed and the content will be scrollable so that the entire dialog can still be seen above the fold
        * Subject field > text input ([PF specs](https://www.patternfly.org/v4/documentation/react/components/textinput))
          * mandatory field
        * Message field > text area ([PF specs](https://www.patternfly.org/v4/documentation/react/components/textarea))
          * mandatory field
        * Buttons:
          * Submit button [Disabled state until all conditions required to submit the form are met]
          * Cancel button [Always enabled]
            * Dismisses modal
        * When user submits the form:
          * the Submit button is replaced by a spinner
            * spinner should stay visible for at least 1.5 seconds (even when the request is resolved earlier)
          * and the input fields are disabled
        * If message is sent successfully:
          * the modal will auto-dismiss
          * and a success toast alert will be displayed
        * If request returns an error:
          * the modal won't auto dismiss
          * the spinner will be replaced by the submit button
          * the input fields will be enabled again (to allow user eventually copy paste their content)
          * an inline warning message will be displayed above the form buttons -->

### _'Delete confirmation'_ modal
<!-- * Modal's header includes the name of the current API (Product or Backend) the user is trying to delete -->
* Enter API name > validated text input field [required] ([PF specs](https://www.patternfly.org/v4/documentation/react/components/textinput#invalid))
  * Label text includes the name of the current API the user is trying to delete
  * API name is contained into code tags for easier copy pasting
  * Validation error:
    * Wrong product name on _onType_
* Buttons
  * Delete button [Disabled state until all conditions required to submit the form are met]
    * Primary danger button variant
    * Submits form
  * Cancel button [Always enabled]
    * Dismisses modal
