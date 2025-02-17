import { mount } from 'enzyme'

import { ExpirationDatePicker } from 'AccessTokens/components/ExpirationDatePicker'

import type { ExpirationItem, Props } from 'AccessTokens/components/ExpirationDatePicker'
import type { ReactWrapper } from 'enzyme'

const defaultProps: Props = {
  id: 'expires_at',
  label: 'Expires in',
  tzOffset: 0
}

const msInADay = 60 * 60 * 24 * 1000

/**
 * Returns a future date in the specified number of days
 * @param {number} days
 * @return {Date}
 */
const futureDateInNDays = (days: number): Date => {
  return new Date(new Date().getTime() + msInADay * days)
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<ExpirationDatePicker {...{ ...defaultProps, ...props }} />)

const selectItem = (wrapper: ReactWrapper<any, Readonly<object>>, item: ExpirationItem) => {
  wrapper.find('select.pf-c-form-control-expiration option').forEach((op) => {
    const elem: HTMLOptionElement = op.getDOMNode()
    elem.selected = elem.value === item.id // Mark option as selected if it's value matches the given one
  })
  wrapper.find('select.pf-c-form-control-expiration').simulate('change')
}

const pickDate = (wrapper: ReactWrapper<any, Readonly<object>>) => {
  /*
   * Pick tomorrow, to do so, we click on the date in the calendar that is already selected (tomorrow is set by default).
   * The difference between the date loaded by default and the manually selected one is on manual selection the time is 
   * reset to 00:00:00, while on initial load the current time is set.
   * In any case, we return the picked date to the caller.
   */
  const targetDate = new Date()
  targetDate.setHours(0)
  targetDate.setMinutes(0)
  targetDate.setSeconds(0)
  targetDate.setMilliseconds(0)

  const tomorrowButton = wrapper.find('.pf-m-selected > button')

  tomorrowButton.simulate('click')
  targetDate.setDate(targetDate.getDate() + 1)
  return targetDate
}

const dateFormatter = Intl.DateTimeFormat('en-US', {
  month: 'long', day: 'numeric', year: 'numeric', hour: 'numeric', minute: 'numeric', hour12: false
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toEqual(true)
})

describe('select a period', () => {
  const targetItem: ExpirationItem = { id: '90', label: '90 days', period: 90 }

  it('should update hint to the correct date', () => {
    const wrapper = mountWrapper()
    const targetDate = futureDateInNDays(targetItem.period)
    const expectedHint = `The token will expire on ${dateFormatter.format(targetDate)}`

    selectItem(wrapper, targetItem)
    const hint = wrapper.find('.pf-c-form__helper-text').text()

    expect(hint).toBe(expectedHint)
  })

  it('should update hidden input value to the correct timestamp', () => {
    const wrapper = mountWrapper()
    const targetDate = futureDateInNDays(targetItem.period)

    selectItem(wrapper, targetItem)
    const value = new Date(wrapper.find(`input#${defaultProps.id}`).prop('value') as string)

    expect(value).toBeWithinSecondsFrom(targetDate)
  })
})

describe('select "Custom"', () => {
  const targetItem: ExpirationItem = { id: 'custom', label: 'Custom...', period: 0 }

  it('should show a calendar', () => {
    const wrapper = mountWrapper()

    selectItem(wrapper, targetItem)
    const calendar = wrapper.find('.pf-c-calendar-month')

    expect(calendar.exists()).toBe(true)
  })

  describe('pick a date from the calendar', () => {
    it('should update hint to the correct date', () => {
      const wrapper = mountWrapper()

      selectItem(wrapper, targetItem)
      const targetDate = pickDate(wrapper)
      const expectedHint = `The token will expire on ${dateFormatter.format(targetDate)}`
      const hint = wrapper.find('.pf-c-form__helper-text').text()

      expect(hint).toBe(expectedHint)
    })

    it('should update hidden input value to the correct timestamp', () => {
      const wrapper = mountWrapper()

      selectItem(wrapper, targetItem)
      const targetDate = pickDate(wrapper)
      const value = new Date(wrapper.find(`input#${defaultProps.id}`).prop('value') as string)

      expect(value).toBeWithinSecondsFrom(targetDate)
    })
  })
})

describe('select "No expiration"', () => {
  const targetItem: ExpirationItem = { id: 'no-exp', label: 'No expiration', period: 0 }

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

describe('time zone matches', () => {
  it('should not show a warning', ()=> {
    jest.spyOn(Date.prototype, 'getTimezoneOffset').mockImplementation(() => (0))
    const wrapper = mountWrapper()

    expect(wrapper.exists('.pf-c-form__group-label-help')).toEqual(false)
  })
})

describe('time zone mismatches', () => {
  it('should show a warning', ()=> {
    jest.spyOn(Date.prototype, 'getTimezoneOffset').mockImplementation(() => (-120))
    const wrapper = mountWrapper()

    expect(wrapper.exists('.pf-c-form__group-label-help')).toEqual(true)
  })
})