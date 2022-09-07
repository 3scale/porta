import React from 'react';
import {shallow, mount} from 'enzyme'

import {ServiceDiscoveryForm} from 'NewService'
import {FormWrapper, ErrorMessage, ServiceDiscoveryListItems} from 'NewService/components/FormElements'
import * as utils from 'utilities/fetchData'

const props = {
  formActionPath: 'action-path',
  setLoadingProjects: () => {}
} as const

it('should render itself', () => {
  const wrapper = shallow(<ServiceDiscoveryForm {...props}/>)
  const form = wrapper.find('#service_source')
  expect(form.exists()).toEqual(true)
  expect(form.props().formActionPath).toEqual('action-path')
})

it('should render `FormWrapper` child', () => {
  const wrapper = shallow(<ServiceDiscoveryForm {...props}/>)
  expect(wrapper.find(FormWrapper).exists()).toEqual(true)
})

it('should render `ServiceDiscoveryListItems` child', () => {
  const wrapper = shallow(<ServiceDiscoveryForm {...props}/>)
  expect(wrapper.find(ServiceDiscoveryListItems).exists()).toEqual(true)
})

describe('fetchProjects', () => {
  const fetch = jest.spyOn(utils, 'fetchData')

  afterEach(() => {
    fetch.mockClear()
  })

  it('should render an error when fetching projects is unsuccessful', done => {
    const msg = 'Something went wrong'
    fetch.mockImplementation(url => { throw new Error(msg) })

    const wrapper = mount(<ServiceDiscoveryForm {...props}/>)

    expect(wrapper.find(ErrorMessage).exists()).toBe(true)
    expect(wrapper.find(ErrorMessage).text()).toContain(msg)

    setImmediate(done)
  })

  it('should fetch projects when first redendered', done => {
    const projects = [{ name: 'project_00' }]
    fetch.mockImplementation(url => projects)

    const setState = jest.fn(val => {
      expect(val).toEqual(projects)
      done()
    })
    const useState = jest.spyOn(React, 'useState')
      .mockImplementationOnce(init => [init, setState])

    mount(<ServiceDiscoveryForm {...props}/>)

    expect(useState).toHaveBeenCalled()
    expect(fetch).toHaveBeenCalled()
  })
})
