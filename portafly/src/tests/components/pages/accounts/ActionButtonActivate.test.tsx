import React from 'react'

import { render } from 'tests/custom-render'
import { ActionButtonActivate } from 'components'

it('should render properly', () => {
  const { getByText, getByRole } = render(<ActionButtonActivate />)
  expect(getByRole('button')).toBeInTheDocument()
  expect(getByText(/actions_column_options.activate/)).toBeInTheDocument()
})
