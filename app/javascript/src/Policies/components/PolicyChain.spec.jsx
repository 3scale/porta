import React from 'react'
import Enzyme, { mount } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import {PolicyChain, SortableList, SortableItem, DragHandle} from './PolicyChain'

Enzyme.configure({ adapter: new Adapter() })

const policies = [
  {id: '1', enabled: true, name: 'cors', humanName: 'CORS', summary: 'CORS', description: 'CORS headers', version: '1.0.0', configuration: {}, schema: {}},
  {id: '2', enabled: true, name: 'echo', humanName: 'Echo', summary: 'Echo', description: 'Echoes the request', version: '1.0.0', configuration: {}, schema: {}}
]

describe('PolicyChain Components', () => {
  describe('PolicyChain', () => {
    function setup () {
      const props = {
        visible: true,
        chain: policies,
        actions: {
          openPolicyRegistry: jest.fn(),
          editPolicy: jest.fn(),
          sortPolicyChain: jest.fn()
        }
      }

      const chainWrapper = mount(<PolicyChain {...props} />)

      return {
        policies,
        props,
        chainWrapper
      }
    }
    it('should render self', () => {
      const {chainWrapper} = setup()
      expect(chainWrapper.find('section').hasClass('PolicyChain')).toBe(true)
    })

    it('should render subcomponents', () => {
      const {chainWrapper} = setup()
      expect(chainWrapper.find(SortableList).exists()).toBe(true)
      expect(chainWrapper.find(SortableItem).length).toBe(2)
    })
  })

  describe('SortableList', () => {
    function setup () {
      const props = {
        items: policies.concat(
          { id: '3', enabled: false, name: 'headers', humanName: 'Headers',
            summary: 'Headers summary', description: 'Headers description',
            version: 'builtin', configuration: {}, schema: {} }),
        visible: true,
        editPolicy: jest.fn()
      }

      const sortableListWrapper = mount(<SortableList {...props} />)
      const firstSortableItem = sortableListWrapper.find(SortableItem).first()

      return { sortableListWrapper, firstSortableItem, props }
    }

    it('should render self correctly and subcomponents', () => {
      const {sortableListWrapper, firstSortableItem} = setup()
      expect(sortableListWrapper.find('ul').hasClass('list-group')).toBe(true)

      expect(firstSortableItem.find('li').hasClass('Policy')).toBe(true)
      expect(firstSortableItem.find('.Policy-version').text()).toBe('1.0.0')
      expect(firstSortableItem.find('.Policy-summary').text()).toBe('CORS')
      expect(firstSortableItem.find(DragHandle).exists()).toBe(true)
    })

    it('should show correctly disabled policies', () => {
      const {sortableListWrapper} = setup()
      const lastSortableItem = sortableListWrapper.find(SortableItem).last()

      expect(lastSortableItem.find('li').hasClass('Policy--disabled')).toBe(true)
    })

    it('should call editPolicy when edit button is clicked', () => {
      const {firstSortableItem, props} = setup()
      expect(props.editPolicy.mock.calls.length).toBe(0)
      firstSortableItem.find('article').simulate('click')
      expect(props.editPolicy.mock.calls.length).toBe(1)
    })
  })
})
