import React from 'react'

import { render } from 'tests/custom-render'
import { ActionButtonImpersonate } from 'components'

it('should render properly', () => {
  const { getByText, getByRole } = render(<ActionButtonImpersonate />)
  expect(getByRole('button')).toBeInTheDocument()
  expect(getByText('actions_column_options.act_as')).toBeInTheDocument()
})
