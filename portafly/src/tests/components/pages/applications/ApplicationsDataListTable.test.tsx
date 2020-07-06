import React from 'react'
import { render } from 'tests/custom-render'
import { ApplicationsDataListTable } from 'components'
import { factories } from 'tests/factories'

it('should render', () => {
  const applications = factories.Application.buildList(1)
  const wrapper = render(<ApplicationsDataListTable applications={applications} />)
  expect(wrapper).not.toBeUndefined()
})
