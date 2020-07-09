import React from 'react'

import { fireEvent } from '@testing-library/react'
import { render } from 'tests/custom-render'
import { CreateProductPage } from 'components/pages/product'
import { useAsync, AsyncState } from 'react-async'
import { IProduct } from 'types'

jest.mock('react-async')

const setup = (asyncState: Partial<AsyncState<IProduct[]>>) => {
  (useAsync as jest.Mock).mockReturnValue(asyncState)
  const wrapper = render(<CreateProductPage />)
  const inputs = {
    nameInput: wrapper.getByRole('textbox', { name: 'create.name' }),
    systemNameInput: wrapper.getByRole('textbox', { name: 'create.system_name.label' }),
    createButton: wrapper.getByRole('button', { name: 'shared:shared_elements.create_button' }),
    cancelButton: wrapper.getByRole('button', { name: 'shared:shared_elements.cancel_button' })
  }

  return { ...wrapper, ...inputs }
}

it('button is disabled as long as request is pending', () => {
  const { createButton } = setup({ isPending: true })
  expect(createButton).toHaveProperty('disabled')
})

it('should render an alert if there is an error', () => {
  const { container, getByText } = setup({ error: { name: 'SomeError', message: 'ERROR' } })
  expect(container.querySelector('.pf-c-alert.pf-m-danger')).toBeInTheDocument()
  expect(getByText('ERROR')).toBeInTheDocument()
})

it('should render inline errors', () => {
  const error = {
    validationErrors: {
      name: ['Invalid name', 'duplicated name'],
      system_name: ['Invalid system name']
    }
  }
  const { getByText } = setup({ error })
  expect(getByText(/Invalid name/)).toBeInTheDocument()
  expect(getByText(/duplicated name/)).toBeInTheDocument()
  expect(getByText(/Invalid system name/)).toBeInTheDocument()
})

it('button is disabled as long as it is invalid', () => {
  const { createButton, nameInput, systemNameInput } = setup({ isPending: false })
  expect(createButton.getAttribute('disabled')).not.toBeNull()

  // Only name is good
  fireEvent.change(nameInput, { target: { value: 'My API' } })
  fireEvent.blur(nameInput)
  expect(createButton.getAttribute('disabled')).toBeNull()

  // Both name and systemName is good
  fireEvent.change(systemNameInput, { target: { value: 'my-api' } })
  fireEvent.blur(systemNameInput)
  expect(createButton.getAttribute('disabled')).toBeNull()

  // No name, no good
  fireEvent.change(nameInput, { target: { value: '' } })
  fireEvent.blur(nameInput)
  expect(createButton.getAttribute('disabled')).not.toBeNull()
})
