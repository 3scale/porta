import { mount } from 'enzyme'

import { ExpirationDatePicker } from 'AccessTokens/components/ExpirationDatePicker'

import type { ExpirationItem, Props } from 'AccessTokens/components/ExpirationDatePicker'
import type { ReactWrapper } from 'enzyme'

const defaultProps: Props = {
  id: 'expires_at',
  label: 'Expires in'
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<ExpirationDatePicker {...{ ...defaultProps, ...props }} />)

const selectItem = (wrapper: ReactWrapper<any, Readonly<object>>, item: ExpirationItem) => {
  wrapper.find('select.pf-c-form-control-expiration').simulate('change', { target: { value: item.id.toString() } })
}

const pickDate = (wrapper: ReactWrapper<any, Readonly<object>>) => {
  /*
   * Pick tomorrow, to do so, we get the date selected by default which is today and click the next one.
   * It could happen that today is the last day in the calendar, in that case we pick the previous day, yesterday.
   * In any case, we return the picked date to the caller.
   */
  const targetDate = new Date()
  targetDate.setHours(0)
  targetDate.setMinutes(0)
  targetDate.setSeconds(0)
  targetDate.setMilliseconds(0)

  const tomorrowButton = wrapper.find('.pf-m-selected + td > button')

  if (tomorrowButton.length === 0) {
    // No tomorrow, pick yesterday
    const dayButtons = wrapper.find('button.pf-c-calendar-month__date')
    const yesterdayButton = dayButtons.at(dayButtons.length - 2)

    yesterdayButton.simulate('click')
    targetDate.setDate(targetDate.getDate() - 1)
    return targetDate
  }

  tomorrowButton.simulate('click')
  targetDate.setDate(targetDate.getDate() + 1)
  return targetDate
}

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toEqual(true)
})

describe('select a period', () => {
  const targetItem: ExpirationItem = { id: 4, name: '90 days', period: 90 }

  it('should update hint to the correct date', () => {
    const wrapper = mountWrapper()
    const targetDate = new Date(new Date().getTime() + 1000 * 60 * 60 * 24 * targetItem.period)
    const expectedHint = `The token will expire on ${targetDate.toLocaleDateString()}`

    selectItem(wrapper, targetItem)
    const hint = wrapper.find('.pf-c-form-control-expiration-hint').text()

    expect(hint).toBe(expectedHint)
  })

  it('should update hidden input value to the correct timestamp', () => {
    const wrapper = mountWrapper()
    const targetDate = new Date(new Date().getTime() + 1000 * 60 * 60 * 24 * targetItem.period)
    const expectedValue = targetDate.toISOString().replace(/\.\d{3}Z$/, 'Z')

    selectItem(wrapper, targetItem)
    const value = wrapper.find(`input#${defaultProps.id}`).prop('value')

    expect(value).toBe(expectedValue)
  })
})

describe('select "Custom"', () => {
  const targetItem: ExpirationItem = { id: 5, name: 'Custom...', period: 0 }

  it('should show a calendar', () => {
    const wrapper = mountWrapper()

    selectItem(wrapper, targetItem)
    const calendar = wrapper.find('.pf-c-calendar-month')

    expect(calendar.exists()).toBe(true)
  })

  describe('pick a date from the calendar', () => {
    it('should update hidden input value to the correct timestamp', () => {
      const wrapper = mountWrapper()

      selectItem(wrapper, targetItem)
      const targetDate = pickDate(wrapper)
      const expectedValue = targetDate.toISOString().replace(/\.\d{3}Z$/, 'Z')
      const value = wrapper.find(`input#${defaultProps.id}`).prop('value')

      expect(value).toBe(expectedValue)
    })
  })
})

describe('select "No expiration"', () => {
  const targetItem: ExpirationItem = { id: 6, name: 'No expiration', period: 0 }

  it('should show a warning', () => {
    const wrapper = mountWrapper()

    selectItem(wrapper, targetItem)
    const warning = wrapper.find('.pf-c-alert.pf-m-warning')

    expect(warning.exists()).toBe(true)
  })

  it('should update hidden input value to empty', () => {
    const wrapper = mountWrapper()
    const expectedValue = ''

    selectItem(wrapper, targetItem)
    const value = wrapper.find(`input#${defaultProps.id}`).prop('value')

    expect(value).toBe(expectedValue)
  })
})

