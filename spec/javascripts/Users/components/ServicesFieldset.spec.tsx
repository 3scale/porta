import { mount } from 'enzyme'
import { ServicesFieldset } from 'Users/components/ServicesFieldset'

import type { ReactWrapper } from 'enzyme'
import type { Props } from 'Users/components/ServicesFieldset'
import type { Api } from 'Types'

let wrapper: ReactWrapper

const SERVICES: Api[] = [
  { id: 0, name: 'The Super API', link: '' },
  { id: 1, name: 'Cool Villains', link: '' }
] as Api[]

function getWrapper (testProps?: Partial<Props>) {
  const defaultProps: Props = {
    services: SERVICES,
    onServiceSelected: jest.fn()
  }
  const props: Props = { ...defaultProps, ...testProps }

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
  const service: Api = SERVICES[0]
  wrapper.setProps({ onServiceSelected })

  wrapper.find(`input#user_member_permission_service_ids_${service.id}`).simulate('change')

  expect(onServiceSelected).toHaveBeenCalledWith(service.id)
})
