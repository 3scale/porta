import { mount, shallow } from 'enzyme'

import { ServiceDiscoveryForm } from 'Products/components/ServiceDiscoveryForm'
import * as utils from 'utilities/fetchData'
import { ServiceDiscoveryListItems } from 'Products/components/ServiceDiscoveryListItems'
import { isSubmitDisabled, waitForPromises } from 'utilities/test-utils'

import type { Props } from 'Products/components/ServiceDiscoveryForm'

const defaultProps: Props = {
  loading: false,
  setLoadingProjects: jest.fn()
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<ServiceDiscoveryForm {...{ ...defaultProps, ...props }} />)
const shallowWrapper = (props: Partial<Props> = {}) => shallow(<ServiceDiscoveryForm {...{ ...defaultProps, ...props }} />)

const fetch = jest.spyOn(utils, 'fetchData')

beforeEach(() => {
  fetch.mockClear() // The promise will reject by default.
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toEqual(true)
})

it('should render `ServiceDiscoveryListItems` child', () => {
  const wrapper = shallowWrapper()
  expect(wrapper.exists(ServiceDiscoveryListItems)).toEqual(true)
})

describe('when loading', () => {
  const props = { loading: true }

  it('should show a spinner', () => {
    const wrapper = mountWrapper(props)
    expect(wrapper.exists('.pf-c-spinner')).toEqual(true)
  })

  it('should disable the submit button', () => {
    const wrapper = mountWrapper({ ...props, disabled: false })
    expect(isSubmitDisabled(wrapper)).toEqual(true)
  })
})

describe('when finished loading', () => {
  const props = { loading: false }

  it('should not show a spinner', () => {
    const wrapper = mountWrapper(props)
    expect(wrapper.exists('.pf-c-spinner')).toEqual(false)
  })

  it('should enable the submit button if successful', async () => {
    fetch.mockResolvedValueOnce([])
    const wrapper = mountWrapper({ ...props, disabled: false })
    await(waitForPromises(wrapper))

    expect(isSubmitDisabled(wrapper)).toEqual(false)
  })

  it('should disable the submit button if unsuccessful', async () => {
    const wrapper = mountWrapper({ ...props, disabled: false })
    await(waitForPromises(wrapper))

    expect(isSubmitDisabled(wrapper)).toEqual(true)
  })
})

describe('fetching projects', () => {
  it('should render an error when unsuccessful', async () => {
    const msg = 'Something went wrong'
    fetch.mockRejectedValueOnce(Error(msg))

    const wrapper = mountWrapper()
    await waitForPromises(wrapper)

    expect(wrapper.find('.pf-c-alert').text()).toContain(msg)
  })

  it('should start when first rendered', async () => {
    const projects = ['project_00']
    fetch.mockResolvedValueOnce(projects)

    const wrapper = mountWrapper()
    await waitForPromises(wrapper)

    expect(wrapper.find('select#service_namespace option').length).toEqual(1)
    expect(wrapper.find('select#service_namespace option').at(0).text()).toEqual(projects[0])
  })
})
