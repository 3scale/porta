import * as React from 'react'
import { render } from 'tests/custom-render'
import { StateLabel } from 'components'

it('should render properly', async () => {
  const { container, getByText } = render(<StateLabel state="approved" />)
  expect(container.querySelector('.pf-m-green')).toBeInTheDocument()
  expect(getByText('Approved')).toBeInTheDocument()
})
