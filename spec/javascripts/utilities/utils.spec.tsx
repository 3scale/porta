import React from 'react';
import { mount } from 'enzyme'
import { CSRFToken } from 'utilities'

describe('CSRFToken', () => {
  it('should render itself correctly', () => {
    const windowMock = {
      document: {
        querySelector: (query) => {
          switch (query) {
            case 'head > meta[name~=csrf-param][content]':
              return { content: 'authenticity_token' }
            case 'head > meta[name~=csrf-token][content]':
              return { content: '=42=' }
          }
        }
      }
    } as const
    const wrapper = mount(<CSRFToken win={windowMock} />)

    expect(wrapper.find(CSRFToken).exists()).toBe(true)
    expect(wrapper.find('input').prop('name')).toBe('authenticity_token')
    expect(wrapper.find('input').prop('value')).toBe('=42=')
  })

  it('should return undefined values when csrf-param meta tag is not present', () => {
    const windowMock = {
      document: {
        querySelector: (query) => {
          switch (query) {
            case 'head > meta[name~=csrf-param][content]':
              return undefined
            case 'head > meta[name~=csrf-token][content]':
              return undefined
          }
        }
      }
    } as const
    const wrapper = mount(<CSRFToken win={windowMock} />)

    expect(wrapper.find(CSRFToken).exists()).toBe(true)
    expect(wrapper.find('input').prop('name')).toBeUndefined()
    expect(wrapper.find('input').prop('value')).toBeUndefined()
  })
})
