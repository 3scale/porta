import React from 'react'
import { mount, shallow } from 'enzyme'

import { ServiceDiscoveryForm } from 'NewService/components/ServiceDiscoveryForm'
import * as utils from 'utilities/fetchData'
import { FormWrapper } from 'NewService/components/FormElements/FormWrapper'
import { ErrorMessage } from 'NewService/components/FormElements/ErrorMessage'
import { ServiceDiscoveryListItems } from 'NewService/components/FormElements/ServiceDiscoveryListItems'

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

  it('should render an error when fetching projects is unsuccessful', () => {
    const msg = 'Something went wrong'
    fetch.mockImplementation(() => { throw new Error(msg) })

    const wrapper = mount(<ServiceDiscoveryForm {...props} />)

    expect(wrapper.exists(ErrorMessage)).toEqual(true)
    expect(wrapper.find(ErrorMessage).text()).toContain(msg)
  })

  it('should fetch projects when first redendered', () => {
    const projects = [{ name: 'project_00' }]
    fetch.mockResolvedValue(projects)

    const setState = jest.fn(val => {
      expect(val).toEqual(projects)
    })
    const useState = jest.spyOn(React, 'useState')
      // @ts-expect-error TODO: we should not test Reacts useState but the component's state
      // eslint-disable-next-line @typescript-eslint/no-unsafe-return
      .mockImplementationOnce((init: any) => [init, setState])

    mount(<ServiceDiscoveryForm {...props} />)

    expect(useState).toHaveBeenCalled()
    expect(fetch).toHaveBeenCalled()
  })
})
