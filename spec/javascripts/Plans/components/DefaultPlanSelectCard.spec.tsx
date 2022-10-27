import { mount } from 'enzyme'

import { DefaultPlanSelectCard } from 'Plans/components/DefaultPlanSelectCard'
import { Select } from 'Common/components/Select'
import { openSelect, selectOption } from 'utilities/test-utils'

import type { IRecord } from 'Types'
import type { Props } from 'Plans/components/DefaultPlanSelectCard'

const plan = { id: 1, name: 'My Plan' }
const plans = [plan]
const defaultProps: Props = {
  plans,
  initialDefaultPlan: null,
  path: '/foo/bar'
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<DefaultPlanSelectCard {...{ ...defaultProps, ...props }} />)

it('should render', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should have a helper text', () => {
  const wrapper = mountWrapper()
  const text = 'If an application plan is set as default, 3scale sets this plan upon service subscription.'

  const helperText = wrapper.find('.pf-c-helper-text')

  expect(helperText.text()).toBe(text)
})

it('should have a "no default plan" option', () => {
  const wrapper = mountWrapper()

  selectOption(wrapper, 'No plan selected')

  expect(wrapper.find(Select).props().item!.id).toEqual(-1)
})

it('should be able to select a plan', () => {
  const wrapper = mountWrapper()

  selectOption(wrapper, plan.name)

  expect(wrapper.find(Select).props().item!.id).toEqual(plan.id)
})

it('should disabled the button when clearing select', () => {
  const wrapper = mountWrapper()
  wrapper.find('.pf-c-select__toggle-clear').simulate('click')

  expect(wrapper.find('button[type="submit"]').prop('disabled')).toBe(true)
})

it('should disable the button when the default plan is selected', () => {
  const initialDefaultPlan = { id: 5, name: 'Default plan' } as const
  const wrapper = mountWrapper({ plans: [...plans, initialDefaultPlan], initialDefaultPlan })
  const isButtonDisabled = (disabled: boolean) => { expect(wrapper.find('button[type="submit"]').prop('disabled')).toBe(disabled) }

  isButtonDisabled(true)

  selectOption(wrapper, plan.name)
  isButtonDisabled(false)

  selectOption(wrapper, initialDefaultPlan.name)
  isButtonDisabled(true)
})

it('should disable the plan option when plan already selected', () => {
  const initialDefaultPlan = { id: 5, name: 'Default plan' } as const
  const wrapper = mountWrapper({ plans: [...plans, initialDefaultPlan], initialDefaultPlan })
  const option = (plan: IRecord) => wrapper.find('.pf-c-select__menu-item').findWhere(node => node.type() === 'button' && node.text() === plan.name)
  const isOptionDisabled = (plan: IRecord, disabled: boolean) => { expect(option(plan).prop('className').includes('pf-m-disabled')).toBe(disabled) }

  openSelect(wrapper)
  isOptionDisabled(initialDefaultPlan, true)
  isOptionDisabled(plan, false)

  option(plan).simulate('click')
  openSelect(wrapper)
  isOptionDisabled(initialDefaultPlan, false)
  isOptionDisabled(plan, true)
})

it.todo('should be able to filter by name')
