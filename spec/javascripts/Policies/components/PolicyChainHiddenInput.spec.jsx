import React from 'react'
import Enzyme, { mount } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import { PolicyChainHiddenInput } from 'Policies/components/PolicyChainHiddenInput'

Enzyme.configure({ adapter: new Adapter() })

describe('PolicyRegistry Components', () => {
  const policyChain = [
    {id: '1', enabled: true, name: 'cors', humanName: 'CORS', description: 'CORS headers', version: '1.0.0', configuration: {}, $schema: '', data: {}},
    {id: '2', enabled: true, name: 'echo', humanName: 'Echo', description: 'Echoes the request', version: '1.0.0', configuration: {}, $schema: '', data: {}}
  ]
  function setup () {
    const props = {
      policies: policyChain
    }

    const inputWrapper = mount(<PolicyChainHiddenInput {...props} />)

    return {
      props,
      inputWrapper
    }
  }
  it('should render the input with filtered chain', () => {
    const {inputWrapper} = setup()
    expect(inputWrapper.find('input').get(0).props.value)
      .toEqual('[{"enabled":true,"name":"cors","version":"1.0.0","configuration":{}},{"enabled":true,"name":"echo","version":"1.0.0","configuration":{}}]')
  })
})
