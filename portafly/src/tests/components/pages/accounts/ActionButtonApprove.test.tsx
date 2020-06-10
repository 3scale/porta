import React from 'react'

import { render } from 'tests/custom-render'
import { ActionButtonApprove } from 'components'

it('should render properly', () => {
  const { getByText, getByRole } = render(<ActionButtonApprove />)
  expect(getByRole('button')).toBeInTheDocument()
  expect(getByText(/actions_column_options.approve/)).toBeInTheDocument()
})
