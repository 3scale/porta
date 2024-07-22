import $ from 'jquery'

document.addEventListener('DOMContentLoaded', () => {
  function enableCheckboxes () {
    checkboxesDisabled(false)
  }

  function disableCheckboxes () {
    checkboxesDisabled(true)
  }

  function checkboxesDisabled (action: boolean) {
    $<HTMLInputElement>('#fields_definition_hidden').attr('disabled', action ? 'true' : null)
    $<HTMLInputElement>('#fields_definition_read_only').attr('disabled', action ? 'true' : null)
    $<HTMLInputElement>('#fields_definition_required').attr('disabled', action ? 'true' : null)
  }

  function disableNameField () {
    $<HTMLInputElement>('#fields_definition_name')[0].value = $<HTMLInputElement>('#fields_definition_fieldname')[0].value
    $<HTMLInputElement>('#fields_definition_name').attr('readonly', 'true')
  }

  function clearCheckboxes () {
    $<HTMLInputElement>('#fields_definition_hidden')[0].checked = false
    $<HTMLInputElement>('#fields_definition_read_only')[0].checked = false
    $<HTMLInputElement>('#fields_definition_required')[0].checked = false
  }

  function clearChoices () {
    $<HTMLInputElement>('#fields_definition_choices_for_views')[0].value = ''
  }

  function readOnlyChoices (action: boolean) {
    $('#fields_definition_choices_for_views').attr('readonly', action ? 'true' : null)
  }

  function enableChoices () {
    readOnlyChoices(false)
  }

  // new view
  const $fieldname = $<HTMLInputElement>('#fields_definition_fieldname')
  const requiredFields = $<HTMLInputElement>('#required_fields')[0].value.split(',')

  const fieldNameValue = $fieldname[0].value

  if ($fieldname.length !== 0) {
    $fieldname.on('change', () => {
      if (fieldNameValue === '[new field]') {
        const $name = $<HTMLInputElement>('#fields_definition_name')
        $name.attr('readonly', null)
        $name[0].value = ''
        clearCheckboxes()
        enableCheckboxes()
        clearChoices()
        enableChoices()

      } else if (requiredFields.includes(fieldNameValue)) {
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

  const $required = $<HTMLInputElement>('#fields_definition_required')

  if ($required.length > 0 && $required[0].checked) {
    const $hidden = $<HTMLInputElement>('#fields_definition_hidden')
    $hidden[0].checked = false
    $hidden.attr('disabled', 'true')

    const $readonly = $<HTMLInputElement>('#fields_definition_read_only')
    $readonly[0].checked = false
    $readonly.attr('disabled', 'true')
  }

  //edit view
  if (document.getElementById('fields-definitions-edit-view') !== null) {
    const $name = $('#fields_definition_name')
    $name.attr('readonly', 'true')
    $name.attr('disabled', 'true')
  }

  $required.on('change', () => {
    const $hidden = $<HTMLInputElement>('#fields_definition_hidden')
    const $readonly = $<HTMLInputElement>('#fields_definition_read_only')

    if ($required[0].checked) {
      $hidden[0].checked = false
      $readonly[0].checked = false
      $hidden.attr('disabled', 'true')
      $readonly.attr('disabled', 'true')
    } else {
      $hidden.attr('disabled', null)
      $readonly.attr('disabled', null)
    }
  })
})
