import React from 'react'
import { render } from 'tests/custom-render'
import { ProductDeleteModal } from 'components'
import { factories } from 'tests/factories'
import { fireEvent } from '@testing-library/react'

const product = factories.Product.build()
const onClose = jest.fn()

const setup = () => {
  const wrapper = render(<ProductDeleteModal isOpen product={product} onClose={onClose} />)
  const input = wrapper.getByRole('textbox', { name: 'modal.confirmation_aria_label' })
  const okButton = wrapper.getByRole('button', { name: 'shared:shared_elements.delete_button' })
  const cancelButton = wrapper.getByRole('button', { name: 'shared:shared_elements.cancel_button' })
  return {
    ...wrapper,
    input,
    okButton,
    cancelButton
  }
}

it('shuold render properly', () => {
  const { input, okButton, cancelButton } = setup()

  expect(input).toBeInTheDocument()
  expect(okButton).toBeInTheDocument()
  expect(cancelButton).toBeInTheDocument()
})

it('should disable the submit button if system-name is not issued', () => {
  const { okButton, input } = setup()
  expect(okButton).toHaveAttribute('disabled')

  fireEvent.change(input, { target: { value: product.systemName } })
  expect(okButton).not.toHaveAttribute('disabled')
})
