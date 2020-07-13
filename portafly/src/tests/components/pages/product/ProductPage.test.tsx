import React from 'react'
import { render } from 'tests/custom-render'
import { ProductPage } from 'components'
import { factories } from 'tests/factories'
import { useAsync, AsyncState } from 'react-async'
import { IProductOverview } from 'types'

const product = factories.Product.build()

jest.mock('react-async')

const setup = (asyncState: Partial<AsyncState<IProductOverview>>) => {
  (useAsync as jest.Mock).mockReturnValue(asyncState)
  return render(<ProductPage productId={product.id.toString()} />)
}

describe('when it is loading', () => {
  it('should show a spinner', () => {
    const { container, getByText } = setup({ isPending: true })

    expect(container.querySelector('.pf-c-spinner')).toBeInTheDocument()
    expect(getByText(/loading/)).toBeInTheDocument()
  })
})

describe('when there is an error', () => {
  it('should show an alert', () => {
    const { getByText } = setup({ isPending: false, error: new Error('Not Found') })

    expect(getByText('Not Found')).toBeInTheDocument()
    expect(getByText('Danger alert:')).toBeInTheDocument()
  })
})

describe('when the product is loaded', () => {
  it('should render properly', () => {
    const { getByText } = setup({ isPending: false, data: product })

    expect(getByText('button_edit')).toBeInTheDocument()
    expect(getByText('button_delete')).toBeInTheDocument()
    expect(getByText(product.name)).toBeInTheDocument()
  })
})
