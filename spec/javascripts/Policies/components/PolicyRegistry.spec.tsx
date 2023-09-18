import { mount } from 'enzyme'

import { PolicyRegistry } from 'Policies/components/PolicyRegistry'
import { PolicyTile } from 'Policies/components/PolicyTile'

import type { RegistryPolicy } from 'Policies/types'

const policies: RegistryPolicy[] = [
  { $schema: '', name: 'apicast', humanName: 'Apicast', summary: 'Apicast summary', description: ['Apicast description'], version: '1.0.0', schema: {}, configuration: {} },
  { $schema: '', name: 'cors', humanName: 'CORS', summary: 'CORS summary', description: ['CORS headers'], version: '1.0.0', schema: {}, configuration: {} },
  { $schema: '', name: 'echo', humanName: 'Echo', summary: 'Echo summary', description: ['Echoes the request'], version: '1.0.0', schema: {}, configuration: {} },
  { $schema: '', name: 'headers', humanName: 'Headers', summary: 'Headers summary', description: ['Allows setting Headers'], version: '1.0.0', schema: {}, configuration: {} }
]

const props = {
  visible: true,
  items: policies,
  actions: {
    addPolicy: jest.fn(),
    closePolicyRegistry: jest.fn()
  }
}

const mountWrapper = () => mount(<PolicyRegistry {...props} />)

it('should render self', () => {
  const registryWrapper = mountWrapper()
  expect(registryWrapper.exists('.PolicyRegistry')).toEqual(true)
})

it('should render subcomponents', () => {
  const registryWrapper = mountWrapper()
  const policyList = registryWrapper.find('ul')
  expect(policyList.hasClass('list-group')).toEqual(true)
  expect(policyList.find('.Policy').length).toBe(3)
})

it('should call addPolicy with the right value', () => {
  const registryWrapper = mountWrapper()

  const item = registryWrapper.find(PolicyTile).first()
  item.props().onClick()

  expect(props.actions.addPolicy).toHaveBeenLastCalledWith({
    $schema: '',
    name: 'cors',
    humanName: 'CORS',
    summary: 'CORS summary',
    description: ['CORS headers'],
    version: '1.0.0',
    schema: {},
    configuration: {}
  })
})
