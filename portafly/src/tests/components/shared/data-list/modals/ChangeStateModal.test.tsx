import React from 'react'

import { render } from 'tests/custom-render'
import { fireEvent } from '@testing-library/react'
import { ChangeStateModal } from 'components'
import { CategoryOption } from 'types'

const states: CategoryOption[] = [
  { name: 'approved', humanName: 'Approved' },
  { name: 'pending', humanName: 'Pending' }
]

const setup = () => {
  const wrapper = render(<ChangeStateModal items={['test']} states={states} />)
  const select = wrapper.baseElement.querySelector('[id="state"]') as HTMLElement

  return { ...wrapper, select }
}

it('should disable its submit button when any field is empty', () => {
  const { getByText, select } = setup()
  const submitButton = getByText('modals.change_state.send')

  expect(submitButton).toBeDisabled()

  fireEvent.change(select, { target: { value: states[0].name } })
  expect(submitButton).not.toBeDisabled()
})

it('should be able to select a state', () => {
  const { getByText } = setup()
  states.forEach(({ humanName }) => (
    expect(getByText(humanName)).toBeInTheDocument()
  ))
})
