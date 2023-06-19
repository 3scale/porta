/* eslint-disable @typescript-eslint/require-await -- There are some async process inside this component that needs
to run, adding async to the act callback is a trick to allow them to finish */
import { act } from 'react-dom/test-utils'
import { mount } from 'enzyme'

import { BASE_PATH, ServiceDiscoveryListItems } from 'Products/components/ServiceDiscoveryListItems'
import * as utils from 'utilities/fetchData'
import { waitForPromises } from 'utilities/test-utils'

import type { FormEvent } from 'react'
import type { Props } from 'Products/components/ServiceDiscoveryListItems'

const projects = ['project_00', 'project_01']
const fakeServices = ['service_00', 'service_01']
const onError = jest.fn()
const defaultProps: Props = {
  projects,
  onError
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<ServiceDiscoveryListItems {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toEqual(true)
  expect(wrapper.find('select[id="service_namespace"][name="service[namespace]"]')).toHaveLength(1)
  expect(wrapper.find('select[id="service_name"][name="service[name]"]')).toHaveLength(1)
})

describe('fetching services', () => {
  const fetch = jest.spyOn(utils, 'fetchData')

  beforeEach(() => {
    fetch.mockResolvedValueOnce(fakeServices)
  })

  afterEach(() => {
    fetch.mockClear()
  })

  it('should fetch services with a project is selected', async () => {
    const namespace = 'my-project'
    const wrapper = mountWrapper()
    await waitForPromises(wrapper)

    await act(async () => {
      wrapper.find('select#service_namespace').prop('onChange')!({ currentTarget: { value: namespace } } as FormEvent<HTMLSelectElement>)
    })

    expect(fetch).toHaveBeenLastCalledWith(`${BASE_PATH}/namespaces/${namespace}/services.json`)
  })

  it('should re fetch services when the list of projects is updated', async () => {
    const wrapper = mountWrapper()
    await waitForPromises(wrapper)

    expect(fetch).toHaveBeenLastCalledWith(`${BASE_PATH}/namespaces/${projects[0]}/services.json`)

    const newProject = 'project_03'
    await act(async () => {
      wrapper.setProps({ projects: [newProject] })
    })

    expect(fetch).toHaveBeenLastCalledWith(`${BASE_PATH}/namespaces/${newProject}/services.json`)
  })

  it('should disable the inputs while in progress', async () => {
    const wrapper = mountWrapper()
    expect(wrapper.find('select').everyWhere(n => n.prop('disabled') === true)).toEqual(true)

    // Assert selects are not disabled after fetched
    await waitForPromises(wrapper)
    wrapper.update()
    expect(wrapper.find('select').everyWhere(n => n.prop('disabled') === false)).toEqual(true)
  })
})
