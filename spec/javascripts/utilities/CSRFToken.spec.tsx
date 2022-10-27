import { mount } from 'enzyme'

import type { FunctionComponent } from 'react'
import type { Props } from 'utilities/CSRFToken'

// eslint-disable-next-line @typescript-eslint/no-unsafe-member-access
const CSRFToken = jest.requireActual('utilities/CSRFToken').CSRFToken as FunctionComponent<Props>

it('should render itself correctly', () => {
  const windowMock = {
    document: {
      querySelector: (query: string): unknown => {
        switch (query) {
          case 'head > meta[name~=csrf-param][content]':
            return { content: 'authenticity_token' }
          case 'head > meta[name~=csrf-token][content]':
            return { content: '=42=' }
        }
      }
    }
  }
  const wrapper = mount(<CSRFToken win={windowMock as Window} />)

  expect(wrapper.find(CSRFToken).exists()).toBe(true)
  expect(wrapper.find('input').prop('name')).toBe('authenticity_token')
  expect(wrapper.find('input').prop('value')).toBe('=42=')
})

it('should return undefined values when csrf-param meta tag is not present', () => {
  const windowMock = {
    document: {
      querySelector: (query: string): unknown => {
        switch (query) {
          case 'head > meta[name~=csrf-param][content]':
            return undefined
          case 'head > meta[name~=csrf-token][content]':
            return undefined
        }
      }
    }
  }
  const wrapper = mount(<CSRFToken win={windowMock as Window} />)

  expect(wrapper.find(CSRFToken).exists()).toBe(true)
  expect(wrapper.find('input').prop('name')).toBeUndefined()
  expect(wrapper.find('input').prop('value')).toBeUndefined()
})
