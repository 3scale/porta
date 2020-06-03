import React from 'react'

import { render } from 'tests/custom-render'
import { ChangeStateModal } from 'components/data-list'
import { fireEvent } from '@testing-library/react'

it('should disable its submit button when any field is empty', () => {
  const { baseElement, getByText } = render(<ChangeStateModal items={['test']} />)
  const select = baseElement.querySelector('[id="state"]') as HTMLElement
  const submitButton = getByText('modals.change_state.send')

  expect(submitButton).toBeDisabled()

  fireEvent.change(select, { target: { value: 'approved' } })
  expect(submitButton).not.toBeDisabled()
})
