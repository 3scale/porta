import React from 'react'
import { render } from 'tests/custom-render'
import { factories } from 'tests/factories'
import { PlanOverviewLink } from 'components'

const plan = factories.Plan.build()

const setup = () => {
  const wrapper = render(<PlanOverviewLink plan={plan} />)
  const row = wrapper.getByText(plan.name).closest('a') as HTMLElement
  return { ...wrapper, row }
}

it('should render properly', () => {
  const { row } = setup()
  expect(row).toBeInTheDocument()
})

it('should have a link', () => {
  const { row } = setup()
  expect(row.getAttribute('aria-label')).toBe('plan_overview_link_aria_label')
})

it('should point to the correct url', () => {
  const { row } = setup()
  expect(row.getAttribute('href')).toMatch(`/plans/${plan.id}`)
})
