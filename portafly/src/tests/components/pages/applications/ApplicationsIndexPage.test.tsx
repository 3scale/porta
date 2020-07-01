import React from 'react'

import { render } from 'tests/custom-render'
import { ApplicationsIndexPage } from 'components'
import { useAsync, AsyncState } from 'react-async'
import { IApplication } from 'types'
import { factories } from 'tests/factories'

jest.mock('react-async')

const setup = (asyncState: Partial<AsyncState<IApplication[]>>) => {
  (useAsync as jest.Mock).mockReturnValueOnce(asyncState)
  const match = { params: { accountId: '0' } }
  return render(<ApplicationsIndexPage computedMatch={match} />)
}

it('should have a button to create an application', () => {
  const { getByText } = setup({})
  expect(getByText('create_application_button')).toBeInTheDocument()
})

describe('when the request is pending', () => {
  it('should render a loading spinner', () => {
    const wrapper = setup({ isPending: true })
    expect(wrapper.container.querySelector('.pf-c-spinner')).toBeInTheDocument()
    expect(wrapper.getByText(/loading/)).toBeInTheDocument()
  })
})

describe('when backend returns an error', () => {
  it('should render an alert', () => {
    const wrapper = setup({ error: { name: 'SomeError', message: 'ERROR' } })
    expect(wrapper.container.querySelector('.pf-c-alert.pf-m-danger')).toBeInTheDocument()
    expect(wrapper.getByText('ERROR')).toBeInTheDocument()
  })
})

describe('when backend returns a list of applications', () => {
  it('should render a table with accounts', () => {
    const applications = factories.Application.buildList(3)
    const wrapper = setup({ data: applications })
    applications.forEach((app: IApplication) => (
      expect(wrapper.getByText(app.name)).toBeInTheDocument()
    ))
  })
})
