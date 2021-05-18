// @flow

import React from 'react'
import { act } from 'react-dom/test-utils'
import { DefaultPlanSelectCard } from 'Plans'
import { mount } from 'enzyme'

import * as alert from 'utilities/alert'
const noticeSpy = jest.spyOn(alert, 'notice')
const errorSpy = jest.spyOn(alert, 'error')

jest.mock('utilities/ajax')
import * as ajax from 'utilities/ajax'
const post = (ajax.post: JestMockFn<empty, any>)

const plan = { id: 1, name: 'My Plan' }
const props = {
  product: { id: 0, name: 'My API', appPlans: [plan], systemName: 'my_api' },
  initialDefaultPlan: null,
  path: '/foo/bar'
}

it('should render', () => {
  const wrapper = mount(<DefaultPlanSelectCard {...props} />)
  expect(wrapper.exists()).toBe(true)
})

it('should show a success message if request goes well', async () => {
  post.mockResolvedValue({ ok: true })
  const wrapper = mount(<DefaultPlanSelectCard {...props} />)

  await act(async () => {
    wrapper.find('DefaultPlanSelect').invoke('onSelectPlan')(plan)
  })

  expect(noticeSpy).toHaveBeenCalledWith('Default plan was updated')
})

it('should show an error message when selected plan does not exist', async () => {
  post.mockResolvedValueOnce({ status: 404 })
  const wrapper = mount(<DefaultPlanSelectCard {...props} />)

  await act(async () => {
    wrapper.find('DefaultPlanSelect').invoke('onSelectPlan')(plan)
  })

  expect(errorSpy).toHaveBeenCalledWith("The selected plan doesn't exist.")
})

it('should show an error message when server returns an error', async () => {
  post.mockResolvedValue({ status: 403 })
  const wrapper = mount(<DefaultPlanSelectCard {...props} />)

  await act(async () => {
    wrapper.find('DefaultPlanSelect').invoke('onSelectPlan')(plan)
  })

  expect(errorSpy).toHaveBeenCalledWith('Plan could not be updated')
})

it('should show an error message when connection fails', async () => {
  // $FlowExpectedError[cannot-write] suppress error logs during test
  console.error = jest.fn()

  post.mockRejectedValue()
  const wrapper = mount(<DefaultPlanSelectCard {...props} />)

  await act(async () => {
    wrapper.find('DefaultPlanSelect').invoke('onSelectPlan')(plan)
  })

  expect(errorSpy).toHaveBeenCalledWith('An error ocurred. Please try again later.')
})
