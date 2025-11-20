document.addEventListener('DOMContentLoaded', () => {
  const select = document.querySelector<HTMLSelectElement>('#fields_definition_fieldname')

  // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-non-null-assertion
  const { requiredFields } = (document.querySelector<HTMLFormElement>('form.fields_definition')!).dataset

  const nameInput = document.getElementById('fields_definition_name') as HTMLInputElement
  const checkboxes = document.querySelectorAll<HTMLInputElement>('input.pf-c-check__input')
  const choices = document.getElementById('fields_definition_choices_for_views') as HTMLTextAreaElement

  select?.addEventListener('change', () => {
    if (isThereUnsavedChanges() && !window.confirm('Changes will be lost.')) {
      // TODO: select previous value and don't erase anything
      // return
    }

    const selectedOption = select.selectedOptions[0].value

    checkboxes.forEach(input => { input.checked = false })
    choices.value = ''
    choices.readOnly = false

    if (selectedOption === '[new field]') {
      nameInput.readOnly = false
      nameInput.value = ''
      checkboxes.forEach(input => { input.disabled = false })
      disableCheckboxes(false)

    } else {
      nameInput.readOnly = true
      nameInput.value = selectedOption
      // eslint-disable-next-line @typescript-eslint/no-unsafe-argument, @typescript-eslint/no-unsafe-call, @typescript-eslint/no-non-null-assertion
      disableCheckboxes(requiredFields!.includes(selectedOption))
    }
  })

  function disableCheckboxes (disable = true) {
    checkboxes.forEach(input => { input.disabled = disable })
  }

  function isThereUnsavedChanges (): boolean {
    return document.querySelector('input.pf-c-check__input:checked') !== null
      || choices.value !== ''
  }

  const requiredCheckbox = document.getElementById('fields_definition_required') as HTMLInputElement | null
  const hiddenCheckbox = document.getElementById('fields_definition_hidden') as HTMLInputElement
  const readOnlyCheckbox = document.getElementById('fields_definition_read_only') as HTMLInputElement

  requiredCheckbox?.addEventListener('change', () => {
    const { checked } = requiredCheckbox

    hiddenCheckbox.disabled = checked
    void (hiddenCheckbox.nextElementSibling as HTMLLabelElement).classList.toggle('pf-m-disabled', checked)

    readOnlyCheckbox.disabled = checked
    void (readOnlyCheckbox.nextElementSibling as HTMLLabelElement).classList.toggle('pf-m-disabled', checked)

    if (checked) {
      hiddenCheckbox.checked = false
      readOnlyCheckbox.checked = false
    }
  })
})
