import { mount } from 'enzyme'
import { ServicesFieldset } from 'Users/components/ServicesFieldset'

import type { Props } from 'Users/components/ServicesFieldset'
import type { Api } from 'Types'

const SERVICES: Api[] = [
  { id: 0, name: 'The Super API', link: '' },
  { id: 1, name: 'Cool Villains', link: '' }
] as Api[]

const defaultProps: Props = {
  services: SERVICES,
  onServiceSelected: jest.fn()
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<ServicesFieldset {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  expect(mountWrapper().find(ServicesFieldset).exists()).toBe(true)
})

it('should render a checkbox for each service', () => {
  SERVICES.forEach(service => {
    expect(mountWrapper().find(`input#user_member_permission_service_ids_${service.id}`).exists()).toBe(true)
  })
})

it('should call onServiceSelected with the service id when being selected', () => {
  const onServiceSelected = jest.fn()
  const service: Api = SERVICES[0]
  const wrapper = mountWrapper({ onServiceSelected })

  wrapper.find(`input#user_member_permission_service_ids_${service.id}`).simulate('change')

  expect(onServiceSelected).toHaveBeenCalledWith(service.id)
})
