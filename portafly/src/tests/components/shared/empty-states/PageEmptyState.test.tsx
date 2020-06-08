import React from 'react'

import { render } from 'tests/custom-render'
import { PageEmptyState } from 'components'

it('should render', () => {
  const msg = 'No results'
  const { getByText } = render(<PageEmptyState msg={msg} />)
  expect(getByText(msg)).toBeInTheDocument()
})
