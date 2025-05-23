import { mount } from 'enzyme'

import { openSelectWithModal as openModal } from 'utilities/test-utils'
import { BackendSelect } from 'BackendApis/components/BackendSelect'

import type { Props } from 'BackendApis/components/BackendSelect'

const onCreateNewBackend = jest.fn()
const onSelect = jest.fn()

const backends = [
  { id: 0, name: 'API A', privateEndpoint: 'a.com', systemName: 'API_A', updatedAt: '' },
  { id: 1, name: 'API B', privateEndpoint: 'b.com', systemName: 'API_B', updatedAt: '' }
]
const defaultProps = {
  backend: null,
  backends,
  canCreateBackend: true,
  onCreateNewBackend,
  error: undefined,
  onSelect
} as const

const mountWrapper = (props: Partial<Props> = {}) => mount(<BackendSelect {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toEqual(true)
})

it('should have a button to create a new backend', () => {
  const wrapper = mountWrapper()

  const button = wrapper.find('button[data-testid="newBackendCreateBackend-buttonLink"]')
  expect(button.exists()).toEqual(true)

  button.simulate('click')
  expect(onCreateNewBackend).toHaveBeenCalledTimes(1)

  wrapper.setProps({ canCreateBackend: false })
  expect(wrapper.exists('button[data-testid="newBackendCreateBackend-buttonLink"]')).toEqual(false)
})

describe('when there are more than 20 backends', () => {
  const backends = new Array(21).fill({}).map((i, j) => ({ id: j, name: `API ${j}`, privateEndpoint: `foo.com/${j}`, systemName: `API_${j}`, updatedAt: '' }))

  it('should have a table with Name, Private Base URL and Last updated', () => {
    const wrapper = mountWrapper({ backends })
    openModal(wrapper)

    expect(wrapper.find('TableModal').prop('cells')).toMatchObject([
      { title: 'Name', propName: 'name' },
      { title: 'Private Base URL', propName: 'privateEndpoint' },
      { title: 'Last updated', propName: 'updatedAt' }
    ])
  })
})
