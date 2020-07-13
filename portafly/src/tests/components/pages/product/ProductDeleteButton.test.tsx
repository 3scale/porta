import React from 'react'
import { render } from 'tests/custom-render'
import { ProductDeleteButton } from 'components'
import { fireEvent } from '@testing-library/react'
import { factories } from 'tests/factories'

const product = factories.Product.build()

const setup = () => {
  const wrapper = render(<ProductDeleteButton product={product} />)
  const button = wrapper.getByRole('button', { name: 'button_delete' })
  return { ...wrapper, button }
}

it('should render properly', () => {
  const { button } = setup()
  expect(button).toBeInTheDocument()
})

it('show a confirmation modal when clicked', () => {
  const { button, queryByText } = setup()

  expect(queryByText('modal.title')).toBeNull()

  fireEvent.click(button)
  expect(queryByText('modal.title')).toBeInTheDocument()
})
