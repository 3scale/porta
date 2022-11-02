import { mount } from 'enzyme'
import { Select } from '@patternfly/react-core'

import { ChangePlanSelectCard } from 'Plans/components/ChangePlanSelectCard'
import { openSelect } from 'utilities/test-utils'
import type { SelectOptionObject } from 'utilities/patternfly-utils'

import type { Props } from 'Plans/components/ChangePlanSelectCard'

const plan = { id: 0, name: 'I am a plan' }
const defaultProps: Props = {
  applicationPlans: [plan, { id: 1, name: 'I am another plan' }],
  path: '/applications/123/change_plan'
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<ChangePlanSelectCard {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toEqual(true)
})

it('should be able to select a plan', () => {
  const wrapper = mountWrapper()
  openSelect(wrapper)
  wrapper.find('SelectOption button').first().simulate('click')

  const selected = wrapper.find(Select).props().selections as SelectOptionObject
  expect(selected.name).toBe(plan.name)
})

it('should have a disabled button', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find('button[type="submit"]').prop('disabled')).toEqual(true)
})

it('should enable the button when a plan is selected', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find('button[type="submit"]').prop('disabled')).toEqual(true)

  openSelect(wrapper)
  wrapper.find('SelectOption button').first().simulate('click')

  expect(wrapper.find('button[type="submit"]').prop('disabled')).toEqual(false)
})

it('should disable the plan already selected', () => {
  const wrapper = mountWrapper()
  const option = () => wrapper.find('SelectOption button').findWhere(n => n.text() === 'I am a plan').first()

  openSelect(wrapper)
  option().simulate('click')
  const selected = wrapper.find(Select).props().selections as SelectOptionObject
  expect(selected.name).toBe(plan.name)

  openSelect(wrapper)
  expect(option().prop('className')).toMatch('pf-m-disabled')
})

// FIXME: input not receiving change event
it.todo('should be able to filter by name')
//   const wrapper = mountWrapper()
//   openSelect(wrapper)
//   expect(wrapper.find('SelectOption')).toHaveLength(2)

//   wrapper.find('input[type="text"]').simulate('change', { target: { value: 'another' } })
//   wrapper.update()
//   expect(wrapper.find('SelectOption')).toHaveLength(1)
// })
