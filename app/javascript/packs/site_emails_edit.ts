import { PopoverWrapper as Popover } from 'Common/components/Popover'
import { safeFromJsonString } from 'utilities/json-utils'
import { EditPageWrapper as EditPage } from 'SiteEmails/components/EditPage'

import type { Props as PopoverProps } from 'Common/components/Popover'
import type { Props as EditPageProps } from 'SiteEmails/components/EditPage'

document.addEventListener('DOMContentLoaded', () => {
  const propsContainerId = 'site-emails-edit'
  const propsContainer = document.getElementById(propsContainerId)

  if (!propsContainer) {
    throw new Error('Container with id ' + propsContainerId + ' could not be found.')
  }

  const popoverProps = safeFromJsonString<PopoverProps>(propsContainer.dataset.popover)

  if (popoverProps) {
    Popover(popoverProps, 'popover-selector')
  } else {
    console.error('Popover props not found and it will not be rendered.')
  }

  const props = safeFromJsonString<EditPageProps>(propsContainer.dataset.props)

  if (props && props.initialProducts.length > 0) {
    EditPage(props, 'add-new-exceptions-react')
  } else {
    console.error('Exception modal props not found and it will not be rendered.')
  }

  const confirmation = propsContainer.dataset.confirmation

  /* eslint-disable @typescript-eslint/no-non-null-assertion */
  document.getElementById('exceptions-stack')!
    .addEventListener('click', (e) => {
      const el = e.target as HTMLElement
      const removeExceptionClicked = Boolean(el.closest('[aria-label="Remove"]'))

      if (removeExceptionClicked && window.confirm(confirmation)) {
        const inputGroup = el.closest<HTMLDivElement>('.pf-c-form__group')!
        inputGroup.classList.add('to-be-removed')

        const input = inputGroup.querySelector<HTMLInputElement>('input[type="email"]')!
        input.value = ''
      }
    })
  /* eslint-enable @typescript-eslint/no-non-null-assertion */
})
