import React from 'react'
import { render } from 'tests/custom-render'
import { ProductEditLink } from 'components'
import { factories } from 'tests/factories'

const product = factories.Product.build()

const setup = () => {
  const wrapper = render(<ProductEditLink product={product} />)
  const link = wrapper.getByRole('link', { name: 'button_edit' })
  return { ...wrapper, link }
}

describe('when product is present', () => {
  it('should redirect to the edit page', () => {
    const { link } = setup()
    expect(link.getAttribute('href')).toMatch(`products/${product.id}/edit`)
  })
})
