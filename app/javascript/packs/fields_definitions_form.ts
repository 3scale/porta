import jquery3 from 'jquery'

const jquery1 = window.$

document.addEventListener('DOMContentLoaded', () => {
  function enableCheckboxes () {
    checkboxesDisabled(false)
  }

  function disableCheckboxes () {
    checkboxesDisabled(true)
  }

  function checkboxesDisabled (action: boolean) {
    jquery3<HTMLInputElement>('#fields_definition_hidden').attr('disabled', action ? 'true' : null)
    jquery3<HTMLInputElement>('#fields_definition_read_only').attr('disabled', action ? 'true' : null)
    jquery3<HTMLInputElement>('#fields_definition_required').attr('disabled', action ? 'true' : null)
  }

  function disableNameField () {
    jquery3<HTMLInputElement>('#fields_definition_name')[0].value = jquery3<HTMLInputElement>('#fields_definition_fieldname')[0].value
    jquery3<HTMLInputElement>('#fields_definition_name').attr('readonly', 'true')
  }

  function clearCheckboxes () {
    jquery3<HTMLInputElement>('#fields_definition_hidden')[0].checked = false
    jquery3<HTMLInputElement>('#fields_definition_read_only')[0].checked = false
    jquery3<HTMLInputElement>('#fields_definition_required')[0].checked = false
  }

  function clearChoices () {
    jquery3<HTMLInputElement>('#fields_definition_choices_for_views')[0].value = ''
  }

  function readOnlyChoices (action: boolean) {
    jquery3('#fields_definition_choices_for_views').attr('readonly', action ? 'true' : null)
  }

  function enableChoices () {
    readOnlyChoices(false)
  }

  // new view
  if (jquery3('#fields_definition_fieldname').length !== 0) {
    jquery3('#fields_definition_fieldname').change(function () {
      if (jquery3<HTMLInputElement>('#fields_definition_fieldname')[0].value === '[new field]') {
        jquery3('#fields_definition_name').attr('readonly', null)
        jquery3<HTMLInputElement>('#fields_definition_name')[0].value = ''
        clearCheckboxes()
        enableCheckboxes()
        clearChoices()
        enableChoices()
      } else if (jquery1.inArray(
        jquery3<HTMLInputElement>('#fields_definition_fieldname')[0].value,
        jquery3<HTMLInputElement>('#required_fields')[0].value.split(',')
      ) !== -1) {
        //non_modifiable fields
        disableNameField()
        clearCheckboxes()
        disableCheckboxes()
        clearChoices()
        enableChoices()
      } else {
        disableNameField()
        clearCheckboxes()
        enableCheckboxes()
        clearChoices()
        enableChoices()
      }
    })
  }

  if (jquery3('#fields_definition_required').length !== 0 && jquery3<HTMLInputElement>('#fields_definition_required')[0].checked) {
    jquery3<HTMLInputElement>('#fields_definition_hidden')[0].checked = false
    jquery3<HTMLInputElement>('#fields_definition_read_only')[0].checked = false
    jquery3('#fields_definition_hidden').attr('disabled', 'true')
    jquery3('#fields_definition_read_only').attr('disabled', 'true')
  }

  //edit view
  if (jquery3('#fields-definitions-edit-view').length !== 0) {
    jquery3('#fields_definition_name').attr('readonly', 'true')
    jquery3('#fields_definition_name').attr('disabled', 'true')
  }

  jquery3('#fields_definition_required').on('change', () => {
    if (jquery3<HTMLInputElement>('#fields_definition_required')[0].checked) {
      jquery3<HTMLInputElement>('#fields_definition_hidden')[0].checked = false
      jquery3<HTMLInputElement>('#fields_definition_read_only')[0].checked = false
      jquery3('#fields_definition_hidden').attr('disabled', 'true')
      jquery3('#fields_definition_read_only').attr('disabled', 'true')
    } else {
      jquery3('#fields_definition_hidden').attr('disabled', null)
      jquery3('#fields_definition_read_only').attr('disabled', null)
    }
  })
})
