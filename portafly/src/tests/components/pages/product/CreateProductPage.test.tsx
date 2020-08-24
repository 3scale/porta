import React from 'react'

import { fireEvent, waitFor } from '@testing-library/react'
import { render } from 'tests/custom-render'
import { CreateProductPage } from 'components/pages/product'
import { useAsync, AsyncState } from 'react-async'
import { IProduct } from 'types'
import { useAlertsContext } from 'components/util/AlertsContext'

jest.mock('react-async')
jest.mock('components/util/AlertsContext')

const addAlert = jest.fn();
(useAlertsContext as jest.Mock).mockReturnValue({ addAlert })

const setup = (asyncState: Partial<AsyncState<IProduct[]>>) => {
  (useAsync as jest.Mock).mockReturnValue(asyncState)
  const wrapper = render(<CreateProductPage />)
  const inputs = {
    nameInput: wrapper.getByRole('textbox', { name: /create.name/ }),
    systemNameInput: wrapper.getByRole('textbox', { name: /create.system_name.label/ }),
    createButton: wrapper.getByRole('button', { name: 'shared:shared_elements.create_button' }),
    cancelButton: wrapper.getByRole('button', { name: 'shared:shared_elements.cancel_button' })
  }

  return { ...wrapper, ...inputs }
}

it('button is disabled as long as request is pending', () => {
  const { createButton } = setup({ isPending: true })
})

it('should render an alert if there is an error', async () => {
  const error = {
    name: 'SomeError',
    message: 'ERROR'
  }
  setup({ error })

  expect(addAlert).toHaveBeenCalledWith(expect.objectContaining({
    title: error.message
  }))
})

it('should render inline errors', async () => {
  const error = {
    name: '',
    message: '',
    validationErrors: {
      name: ['Invalid name', 'duplicated name'],
      system_name: ['Invalid system name']
    }
  }
  const { getByText } = setup({ error })

  await waitFor(() => expect(getByText(/Invalid name/)).toBeInTheDocument())
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
