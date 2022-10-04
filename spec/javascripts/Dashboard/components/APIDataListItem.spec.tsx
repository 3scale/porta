import { mount } from 'enzyme'
import { APIDataListItem } from 'Dashboard/components/APIDataListItem'

import type { Props } from 'Dashboard/components/APIDataListItem'

const defaultProps = {
  api: {
    id: 0,
    link: '',
    links: [],
    name: '',
    type: '',
    updated_at: ''
  }
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<APIDataListItem {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
