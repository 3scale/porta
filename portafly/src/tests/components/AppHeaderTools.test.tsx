import React from 'react'
import { render } from 'tests/custom-render'
import { AppHeaderTools } from 'components'

it('should render propertly', () => {
  const { getByText } = render(<AppHeaderTools />)

  expect(getByText('User Name')).toBeInTheDocument()
})
