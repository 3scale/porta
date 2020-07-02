import * as React from 'react'
import { render } from 'tests/custom-render'
import { StateLabel } from 'components'

it('should set the color of the label no matter the case', async () => {
  const { container, rerender } = render(<StateLabel state="Approved" />)
  expect(container.querySelector('.pf-m-green')).toBeInTheDocument()

  rerender(<StateLabel state="approved" />)
  expect(container.querySelector('.pf-m-green')).toBeInTheDocument()
})
