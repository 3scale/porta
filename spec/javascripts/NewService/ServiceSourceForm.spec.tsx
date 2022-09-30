import { act } from 'react-dom/test-utils'
import { mount, shallow } from 'enzyme'

import { ServiceSourceForm } from 'NewService'

const serviceDiscoveryAuthenticateUrl = 'my-url'
const props = {
  isServiceDiscoveryUsable: true,
  serviceDiscoveryAuthenticateUrl,
  handleFormsVisibility: jest.fn(),
  loadingProjects: false
}

it('should render itself', () => {
  const wrapper = mount(<ServiceSourceForm {...props} />)
  expect(wrapper.find(ServiceSourceForm).exists()).toEqual(true)
})

it('should render all possible sources for the new service', () => {
  const wrapper = shallow(<ServiceSourceForm {...props} />)

  const manual = wrapper.find('[htmlFor="source_manual"]')
  expect(manual.exists()).toBe(true)
  expect(manual.find('input').prop('type')).toBe('radio')
  expect(manual.text()).toBe('Define manually')

  const discovery = wrapper.find('[htmlFor="source_discover"]')
  expect(discovery.exists()).toBe(true)
  expect(discovery.find('input').prop('type')).toBe('radio')
  expect(discovery.text()).toBe('Import from OpenShift')
})

it('should call `handleFormsVisibility` when changing the source', () => {
  const wrapper = shallow(<ServiceSourceForm {...props} />)
  const handleFormsVisibility = jest.fn()
  wrapper.setProps({ handleFormsVisibility })

  wrapper.find('#source_discover').simulate('change')
  expect(handleFormsVisibility).toHaveBeenCalled()
})

it('should render a spinner when loading projects', () => {
  const wrapper = shallow(<ServiceSourceForm {...props} />)

  wrapper.setProps({ loadingProjects: true })
  expect(wrapper.find('.fa-spinner').exists()).toBe(true)

  wrapper.setProps({ loadingProjects: false })
  expect(wrapper.find('.fa-spinner').exists()).toBe(false)
})

it('should render a link to authenticate when Service Discovery is not usable', () => {
  const wrapper = shallow(<ServiceSourceForm {...props} />)

  act(() => {
    wrapper.setProps({ isServiceDiscoveryUsable: false })
  })
  expect(wrapper.find(`a[href="${serviceDiscoveryAuthenticateUrl}"]`).exists()).toBe(true)

  act(() => {
    wrapper.setProps({ isServiceDiscoveryUsable: true })
  })
  expect(wrapper.find(`a[href="${serviceDiscoveryAuthenticateUrl}"]`).exists()).toBe(false)
})
