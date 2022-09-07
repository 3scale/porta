import React from 'react';

import { mount } from 'enzyme'
import { PolicyChainHiddenInput } from 'Policies/components/PolicyChainHiddenInput'

import type { ChainPolicy } from 'Policies/types'

const policies: ChainPolicy[] = [
  { id: 1, enabled: true, name: 'cors', humanName: 'CORS', description: ['CORS headers'], version: '1.0.0', configuration: {}, $schema: '', data: {}, removable: true, summary: '', uuid: '1' },
  { id: 2, enabled: true, name: 'echo', humanName: 'Echo', description: ['Echoes the request'], version: '1.0.0', configuration: {}, $schema: '', data: {}, removable: true, summary: '', uuid: '2' }
]

it('should render itself', () => {
  const wrapper = mount(<PolicyChainHiddenInput policies={policies} />)

  const input = wrapper.find('input')
  expect(input.prop('id')).toBe('proxy[policies_config]')
  expect(input.prop('type')).toBe('hidden')
})

it('should render an input with the parsed policies as value', () => {
  const wrapper = mount(<PolicyChainHiddenInput policies={policies} />)

  const value = wrapper.find('input').prop('value')
  const data = JSON.parse(value)

  expect(data).toHaveLength(policies.length)

  for (const policy of data) {
    expect(policy).toHaveProperty('configuration', {})
    expect(policy).toHaveProperty('name')
    expect(policy).toHaveProperty('version', '1.0.0')
    expect(policy).toHaveProperty('enabled', true)
  }
})
