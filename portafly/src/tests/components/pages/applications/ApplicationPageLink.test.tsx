import React from 'react'
import { render } from 'tests/custom-render'
import { factories } from 'tests/factories'
import { ApplicationPageLink } from 'components'

const application = factories.Application.build()

const setup = () => {
  const wrapper = render(<ApplicationPageLink application={application} />)
  const row = wrapper.getByText(application.name).closest('a') as HTMLElement
  return { ...wrapper, row }
}

it('should render properly', () => {
  const { row } = setup()
  expect(row).toBeInTheDocument()
})

it('should have a link', () => {
  const { row } = setup()
  expect(row.getAttribute('aria-label')).toBe('applications_table.application_overview_link_aria_label')
})

it('should point to the correct url', () => {
  const { row } = setup()
  expect(row.getAttribute('href')).toMatch(`/applications/${application.id}`)
})
