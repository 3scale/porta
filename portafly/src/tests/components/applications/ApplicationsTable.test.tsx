import * as React from 'react'

import { render } from 'tests/setup'
import { ApplicationsTable } from 'components'

export const applications = [{
  name: 'Application Name',
  state: 'Some status',
  account: 'Developer',
  plan: { name: 'Plan Name' },
  created_at: 1234567890
}]

describe('when there are any applications', () => {

  it('should render a table with applications', () => {
    const wrapper = render(<ApplicationsTable applications={applications} />)
    expect(wrapper).toMatchSnapshot()
  })
})

describe('when there are NO applications', () => {

  it('should render an empty view', () => {
    const wrapper = render(<ApplicationsTable applications={[]} />)
    expect(wrapper).toMatchSnapshot()
  })
})
