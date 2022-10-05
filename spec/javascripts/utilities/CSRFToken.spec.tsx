import { mount } from 'enzyme'
import { CSRFToken } from 'utilities/CSRFToken'

it('should render itself correctly', () => {
  const windowMock = {
    document: {
      querySelector: (query: string) => {
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
      querySelector: (query: string) => {
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
