/* eslint-disable @typescript-eslint/require-await -- There are some async process inside this component that needs
to run, adding async to the act callback is a trick to allow them to finish */
import { act } from 'react-dom/test-utils'
import { mount, render, shallow } from 'enzyme'

import { BASE_PATH, ServiceDiscoveryListItems } from 'NewService/components/FormElements/ServiceDiscoveryListItems'
import * as utils from 'utilities/fetchData'

import type { ReactWrapper } from 'enzyme'
import type { FormEvent } from 'react'

const projects = ['project_00', 'project_01']
const fakeServices = ['service_00', 'service_01']
const onError = jest.fn()
const props = { projects, onError }

it('should render itself', () => {
  const wrapper = shallow(<ServiceDiscoveryListItems {...props} />)
  expect(wrapper.exists('#service_name_input')).toEqual(true)
})

it('should render a field to select a project', () => {
  const wrapper = render(<ServiceDiscoveryListItems {...props} />)

  expect(wrapper.find('label[for="service_namespace"]')).toHaveLength(1)
  expect(wrapper.find('select[id="service_namespace"][name="service[namespace]"]')).toHaveLength(1)
})

it('should render a field to select a service', () => {
  const wrapper = render(<ServiceDiscoveryListItems {...props} />)

  expect(wrapper.find('label[for="service_name"]')).toHaveLength(1)
  expect(wrapper.find('select[id="service_name"][name="service[name]"]')).toHaveLength(1)
})

describe('fetchServices', () => {
  const fetch = jest.spyOn(utils, 'fetchData')
    .mockImplementation(() => Promise.resolve(fakeServices))

  afterEach(() => {
    fetch.mockClear()
  })

  it('should fetch services with a project is selected', async () => {
    const namespace = 'my-project'
    let wrapper: ReactWrapper

    await act(async () => {
      wrapper = mount(<ServiceDiscoveryListItems {...props} />)
    })

    await act(async () => {
      wrapper.find('select#service_namespace').prop('onChange')!({ currentTarget: { value: namespace } } as FormEvent<HTMLSelectElement>)
    })

    expect(fetch).toHaveBeenLastCalledWith(`${BASE_PATH}/namespaces/${namespace}/services.json`)
  })

  it('should re fetch services when the list of projects is updated', async () => {
    let wrapper: ReactWrapper

    await act(async () => {
      wrapper = mount(<ServiceDiscoveryListItems {...props} />)
    })

    expect(fetch).toHaveBeenLastCalledWith(`${BASE_PATH}/namespaces/${projects[0]}/services.json`)

    const newProject = 'project_03'
    await act(async () => {
      wrapper.setProps({ projects: [newProject] })
    })

    expect(fetch).toHaveBeenLastCalledWith(`${BASE_PATH}/namespaces/${newProject}/services.json`)
  })

  it('should disable the inputs while fetching services', async () => {
    let wrapper: ReactWrapper

    await act(async () => {
      wrapper = mount(<ServiceDiscoveryListItems {...props} />)
      // Assert selects are disabled right after fetch starts
      wrapper.update()
      expect(wrapper.find('select').everyWhere(n => n.prop('disabled') === true)).toEqual(true)
    })

    // Assert selects are not disabled after fetched
    wrapper!.update()
    expect(wrapper!.find('select').everyWhere(n => n.prop('disabled') === false)).toEqual(true)
  })
})
