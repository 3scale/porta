import React from 'react'

import { render } from 'tests/custom-render'
import { CreateApplicationButton } from 'components'

it('should render properly', () => {
  const { getByRole } = render(<CreateApplicationButton />)
  const button = getByRole('link', { name: 'create_application_button_aria_label' })
  expect(button).toHaveTextContent('create_application_button')
  expect(button.getAttribute('href')).toBe('/applications/new')
})
