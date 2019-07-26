// @flow

import React from 'react'
import {act} from 'react-dom/test-utils'
import Enzyme, {mount, shallow, render} from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import {ServiceDiscoveryListItems} from 'NewService/components/FormElements'
import * as utils from 'utilities/utils'
import { BASE_PATH } from 'NewService'

Enzyme.configure({adapter: new Adapter()})

const projects = ['project_00', 'project_01']
const onError = jest.fn()
const props = { projects, onError }

it('should render itself', () => {
  const wrapper = shallow(<ServiceDiscoveryListItems {...props}/>)
  expect(wrapper.find('#service_name_input').exists()).toEqual(true)
})

it('should render a field to select a project', () => {
  const wrapper = render(<ServiceDiscoveryListItems {...props}/>)

  expect(wrapper.find('label[for="service_namespace"]')).toHaveLength(1)
  expect(wrapper.find('select[id="service_namespace"][name="service[namespace]"]')).toHaveLength(1)
})

it('should render a field to select a service', () => {
  const wrapper = render(<ServiceDiscoveryListItems {...props}/>)

  expect(wrapper.find('label[for="service_name"]')).toHaveLength(1)
  expect(wrapper.find('select[id="service_name"][name="service[name]"]')).toHaveLength(1)
})

describe('fetchServices', () => {
  const fetch = jest.spyOn(utils, 'fetchData')

  afterEach(() => {
    fetch.mockClear()
  })

  it('should fetch services with a project is selected', () => {
    const namespace = 'my-project'
    const wrapper = mount(<ServiceDiscoveryListItems {...props}/>)

    act(() => {
      wrapper.find('select#service_namespace').prop('onChange')({ currentTarget: { value: namespace } })
    })
    expect(fetch).toHaveBeenLastCalledWith(`${BASE_PATH}/namespaces/${namespace}/services.json`)
  })

  it('should re fetch services when the list of projects is updated', () => {
    const wrapper = mount(<ServiceDiscoveryListItems {...props}/>)

    expect(fetch).toHaveBeenLastCalledWith(`${BASE_PATH}/namespaces/${projects[0]}/services.json`)

    const newProject = 'project_03'
    wrapper.setProps({ projects: [newProject] })

    expect(fetch).toHaveBeenLastCalledWith(`${BASE_PATH}/namespaces/${newProject}/services.json`)
  })

  it('should disable the inputs while fetching services', () => {
    fetch.mockImplementation(() => {
      expect(wrapper.find('select').every(n => n.prop('disabled'))).toBe(true)
    })

    const wrapper = mount(<ServiceDiscoveryListItems {...props}/>)

    act(() => {
      wrapper.find('select#service_namespace').prop('onChange')({ currentTarget: { value: 'namespace' } })
    })
  })
})
