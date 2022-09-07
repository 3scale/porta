import React from 'react';
import { mount } from 'enzyme'

import { PolicyRegistry } from 'Policies/components/PolicyRegistry'

describe('PolicyRegistry Component', () => {
  function setup () {
    const policies = [
      {$schema: '', name: 'apicast', humanName: 'Apicast', summary: 'Apicast summary', description: ['Apicast description'], version: '1.0.0', schema: {}, configuration: {}},
      {$schema: '', name: 'cors', humanName: 'CORS', summary: 'CORS summary', description: ['CORS headers'], version: '1.0.0', schema: {}, configuration: {}},
      {$schema: '', name: 'echo', humanName: 'Echo', summary: 'Echo summary', description: ['Echoes the request'], version: '1.0.0', schema: {}, configuration: {}},
      {$schema: '', name: 'headers', humanName: 'Headers', summary: 'Headers summary', description: ['Allows setting Headers'], version: '1.0.0', schema: {}, configuration: {}}
    ]
    const props = {
      visible: true,
      items: policies,
      actions: {
        addPolicy: jest.fn(),
        closePolicyRegistry: jest.fn()
      }
    } as const

    const registryWrapper = mount(<PolicyRegistry {...props} />)

    return {
      policies,
      props,
      registryWrapper
    }
  }

  it('should render self', () => {
    const {registryWrapper} = setup()
    expect(registryWrapper.find('.PolicyRegistry').exists()).toBe(true)
  })

  it('should render subcomponents', () => {
    const {registryWrapper} = setup()
    const policyList = registryWrapper.find('ul')
    expect(policyList.hasClass('list-group')).toBe(true)
    expect(policyList.find('.Policy').length).toBe(3)
  })

  it('should not render apicast policy', () => {
    const {registryWrapper} = setup()
    const policyRegistryItems = registryWrapper.find('PolicyRegistryItem')
    policyRegistryItems.forEach(policyRegistryItem => {
      expect(policyRegistryItem.props().value.name).not.toEqual('apicast')
    })
  })

  it('should have a close button', () => {
    const {registryWrapper, props} = setup()
    const closeRegistryButton = registryWrapper.find('HeaderButton')
    expect(closeRegistryButton.find('.PolicyChain-addPolicy--cancel').exists()).toBe(true)
    closeRegistryButton.simulate('click')
    expect(props.actions.closePolicyRegistry.mock.calls.length).toBe(1);
  })

  it('should call addPolicy with the right value', () => {
    const {registryWrapper, props: { actions }} = setup()

    const item = registryWrapper.find('PolicyTile').first()
    item.props().onClick()

    expect(actions.addPolicy).toHaveBeenLastCalledWith({
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
})
