import React from 'react'
import Enzyme, { mount } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import { PolicyRegistry, PolicyRegistryItem } from 'Policies/components/PolicyRegistry'

Enzyme.configure({ adapter: new Adapter() })

describe('PolicyRegistry Components', () => {
  describe('PolicyRegistry', () => {
    function setup () {
      const policies = [
        {name: 'apicast', humanName: 'Apicast', summary: 'Apicast summary', description: 'Apicast description', version: '1.0.0', schema: {}, configuration: {}},
        {name: 'cors', humanName: 'CORS', summary: 'CORS summary', description: 'CORS headers', version: '1.0.0', schema: {}, configuration: {}},
        {name: 'echo', humanName: 'Echo', summary: 'Echo summary', description: 'Echoes the request', version: '1.0.0', schema: {}, configuration: {}},
        {name: 'headers', humanName: 'Headers', summary: 'Headers summary', description: 'Allows setting Headers', version: '1.0.0', schema: {}, configuration: {}}
      ]
      const props = {
        visible: true,
        items: policies,
        actions: {
          addPolicy: jest.fn(),
          closePolicyRegistry: jest.fn()
        }
      }

      const registryWrapper = mount(<PolicyRegistry {...props} />)

      return {
        policies,
        props,
        registryWrapper
      }
    }

    it('should render self', () => {
      const {registryWrapper} = setup()
      expect(registryWrapper.find('section').hasClass('PolicyRegistryList')).toBe(true)

      const registryProps = registryWrapper.props()
      expect(registryProps.visible).toBe(true)
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
      const closeRegistryButton = registryWrapper.find('CloseRegistryButton div')
      expect(closeRegistryButton.hasClass('PolicyChain-addPolicy--cancel')).toBe(true)
      closeRegistryButton.simulate('click')
      expect(props.actions.closePolicyRegistry.mock.calls.length).toBe(1)
    })
  })

  describe('PolicyRegistryItem', () => {
    function setup () {
      const props = {
        value: {name: 'cors', humanName: 'CORS', summary: 'CORS summary', description: 'CORS headers', version: '1.0.0', schema: {}, configuration: {}},
        addPolicy: jest.fn()
      }
      const registryItemWrapper = mount(<PolicyRegistryItem {...props} />)
      return {
        props,
        registryItemWrapper
      }
    }

    it('should render correctly', () => {
      const {registryItemWrapper} = setup()
      expect(registryItemWrapper.find('article').hasClass('Policy-article')).toBe(true)
      expect(registryItemWrapper.find('.Policy-summary').text()).toBe('CORS summary')
    })

    it('should call addPolicy with the right value', () => {
      const {registryItemWrapper, props} = setup()
      const registryItemProps = registryItemWrapper.props()
      registryItemProps.addPolicy(props.value)
      expect(props.addPolicy.mock.calls[0][0]).toEqual(
        {
          name: 'cors',
          humanName: 'CORS',
          summary: 'CORS summary',
          description: 'CORS headers',
          version: '1.0.0',
          schema: {},
          configuration: {}
        })
    })
  })
})
