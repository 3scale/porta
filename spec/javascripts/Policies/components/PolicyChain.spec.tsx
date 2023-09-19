import { mount } from 'enzyme'
import { DragDrop } from '@patternfly/react-core'

import { PolicyChain } from 'Policies/components/PolicyChain'
import { updateInput } from 'utilities/test-utils'

const policy1 = { uuid: '1', removable: true, enabled: true, name: 'cors', humanName: 'CORS', summary: 'CORS', description: ['CORS headers'], version: '1.0.0', configuration: {}, $schema: '{}' }
const policy2 = { uuid: '2', removable: true, enabled: true, name: 'echo', humanName: 'Echo', summary: 'Echo', description: ['Echoes the request'], version: '1.0.0', configuration: {}, $schema: '{}' }

const defaultProps = {
  visible: true,
  chain: [policy1, policy2],
  actions: {
    openPolicyRegistry: jest.fn(),
    editPolicy: jest.fn(),
    sortPolicyChain: jest.fn()
  }
}

beforeEach(() => {
  jest.clearAllMocks()
})

const mountWrapper = () => mount(<PolicyChain {...defaultProps} />)

it('should render self', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toEqual(true)
})

it('should call editPolicy when clicked', () => {
  const wrapper = mountWrapper()
  const { editPolicy } = defaultProps.actions
  expect(editPolicy.mock.calls.length).toBe(0)

  wrapper.find('article').at(0).simulate('click')
  expect(editPolicy.mock.calls.length).toBe(1)
})

it('should be able to drag and drop any item, unless searching', () => {
  const source = { droppableId: '0', index: 0 }
  const dest = { droppableId: '0', index: 1 }
  const wrapper = mountWrapper()

  expect(wrapper.find(DragDrop).props().onDrop!(source, dest)).toEqual(true)

  updateInput(wrapper, 'foo')
  expect(wrapper.find(DragDrop).props().onDrop!(source, dest)).toEqual(false)
})

it('should be able to rearrange the chain by drag and drop', () => {
  const wrapper = mountWrapper()

  wrapper.find(DragDrop).props().onDrop!(
    { index: 0, droppableId: 'foo' }, // source
    { index: 1, droppableId: 'bar' } // dest
  )

  const { sortPolicyChain } = defaultProps.actions

  expect(sortPolicyChain).toHaveBeenCalledWith([policy2, policy1])
})

it('should be able to filter policies', () => {
  const wrapper = mountWrapper()

  expect(wrapper.find('.pf-c-data-list__item').length).toEqual(2)

  updateInput(wrapper, 'cors')
  expect(wrapper.find('.pf-c-data-list__item').length).toEqual(1)

  updateInput(wrapper, 'empty')
  expect(wrapper.find('.pf-c-data-list__item').length).toEqual(0)
})
