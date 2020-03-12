import * as React from 'react'

import { render } from 'tests/setup'
import { Applications } from 'pages'
import { useGetApplications } from 'dal/Applications'
import { getByLabelText } from '@testing-library/react'

jest.mock('dal/Applications')

export const applications = [{
  name: 'Application Name',
  state: 'Some status',
  account: 'Developer',
  plan: { name: 'Plan Name' },
  created_at: 1234567890
}]

describe('when the request is pending', () => {
  (useGetApplications as jest.Mock).mockReturnValueOnce({ isPending: true })

  it('should render spinner', () => {
    const wrapper = render(<Applications />)
    expect(wrapper).toMatchSnapshot()
  })
})

describe('when backend returns an error', () => {
  (useGetApplications as jest.Mock).mockReturnValueOnce({ error: { message: 'ERROR'} })

  it('should render an alert', () => {
    const wrapper = render(<Applications />)
    expect(wrapper).toMatchSnapshot()
  })
})

describe('when backend returns a list of applications', () => {
  (useGetApplications as jest.Mock).mockReturnValueOnce({ applications })

  it('should render a table with applications', () => {
    const wrapper = render(<Applications />)
    expect(wrapper).toMatchSnapshot()
  })
})
