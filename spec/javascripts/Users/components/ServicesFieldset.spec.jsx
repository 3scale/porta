import React from 'react'
import { mount } from 'enzyme'

import { ServicesFieldset } from 'Users/components/ServicesFieldset'

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
