import React from 'react'
import { mount, shallow } from 'enzyme'

import { ServiceDiscoveryForm } from 'NewService/components/ServiceDiscoveryForm'
import * as utils from 'utilities/fetchData'
import { FormWrapper } from 'NewService/components/FormElements/FormWrapper'
import { ErrorMessage } from 'NewService/components/FormElements/ErrorMessage'
import { ServiceDiscoveryListItems } from 'NewService/components/FormElements/ServiceDiscoveryListItems'
import { waitForPromises } from 'utilities/test-utils'

import type { Props } from 'NewService/components/ServiceDiscoveryForm'

const props: Props = {
  formActionPath: 'action-path',
  setLoadingProjects: jest.fn()
}

it('should render itself', () => {
  const wrapper = shallow(<ServiceDiscoveryForm {...props} />)
  const form = wrapper.find('#service_source')
  expect(form.exists()).toEqual(true)
  expect(form.prop('formActionPath')).toEqual('action-path')
})

it('should render `FormWrapper` child', () => {
  const wrapper = shallow(<ServiceDiscoveryForm {...props} />)
  expect(wrapper.exists(FormWrapper)).toEqual(true)
})

it('should render `ServiceDiscoveryListItems` child', () => {
  const wrapper = shallow(<ServiceDiscoveryForm {...props} />)
  expect(wrapper.exists(ServiceDiscoveryListItems)).toEqual(true)
})

describe('fetchProjects', () => {
  const fetch = jest.spyOn(utils, 'fetchData')

  afterEach(() => {
    fetch.mockClear()
  })

  it('should render an error when fetching projects is unsuccessful', async () => {
    const msg = 'Something went wrong'
    fetch.mockRejectedValueOnce(Error(msg))

    const wrapper = mount(<ServiceDiscoveryForm {...props} />)

    await waitForPromises(wrapper)
    expect(wrapper.find(ErrorMessage).text()).toContain(msg)
  })

  it('should fetch projects when first redendered', async () => {
    const projects = ['project_00']
    const services = ['service_00']
    fetch.mockResolvedValueOnce(projects)
    fetch.mockResolvedValueOnce(services)

    const wrapper = mount(<ServiceDiscoveryForm {...props} />)
    await waitForPromises(wrapper)

    expect(wrapper.find('select#service_namespace option').length).toEqual(1)
    expect(wrapper.find('select#service_namespace option').at(0).text()).toEqual(projects[0])
    expect(wrapper.find('select#service_name option').length).toEqual(1)
    expect(wrapper.find('select#service_name option').at(0).text()).toEqual(services[0])
  })
})
