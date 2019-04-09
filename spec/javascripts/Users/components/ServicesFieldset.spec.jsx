import React from 'react'
import Enzyme, { mount } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import { ServicesFieldset } from 'Users/components/ServicesFieldset'

Enzyme.configure({ adapter: new Adapter() })

let wrapper

const SERVICES = [
  { id: 0, name: 'The Super API', link: '' },
  { id: 1, name: 'Cool Villains', link: '' }
]

function getWrapper (testProps) {
  const defaultProps = {
    services: SERVICES,
    onServiceSelected: jest.fn()
  }
  const props = { ...defaultProps, ...testProps }

  wrapper = mount(<ServicesFieldset {...props} />)
}

beforeEach(() => {
  getWrapper()
})

afterEach(() => {
  wrapper.unmount()
})

it('should render itself', () => {
  expect(wrapper.find(ServicesFieldset).exists()).toBe(true)
})

it('should render a checkbox for each service', () => {
  SERVICES.forEach(service => {
    expect(wrapper.find(`input#user_member_permission_service_ids_${service.id}`).exists()).toBe(true)
  })
})

it('should call onServiceSelected with the service id when being selected', () => {
  const onServiceSelected = jest.fn()
  const service = SERVICES[0]
  wrapper.setProps({ onServiceSelected })

  wrapper.find(`input#user_member_permission_service_ids_${service.id}`).simulate('change')

  expect(onServiceSelected).toHaveBeenCalledWith(service.id)
})

describe('FeatureIndicators', () => {
  const FEATURES_FOR_SERVICES = ['partners', 'monitoring', 'plans']

  it('there should be one per relevant feature, in every service input', () => {
    const serviceHasFeatureIndicators = service => {
      return FEATURES_FOR_SERVICES.every(feature => service.find(`.ServiceAccessList-sectionItem--${feature}`).exists())
    }
    expect(wrapper.find('.ServiceAccessList-item').everyWhere(serviceHasFeatureIndicators)).toBe(true)
  })

  it('should render available if the feature is selected', () => {
    getWrapper({ selectedSections: 'plans' })
    expect(wrapper.find('.ServiceAccessList-sectionItem--plans').exists()).toBe(true)
    expect(wrapper.find('.ServiceAccessList-sectionItem--plans.is-unavailable').exists()).toBe(false)

    expect(wrapper.find('.ServiceAccessList-sectionItem--partners.is-unavailable').exists()).toBe(true)
    expect(wrapper.find('.ServiceAccessList-sectionItem--monitoring.is-unavailable').exists()).toBe(true)
  })
})
