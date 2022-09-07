import React from 'react';
import { mount } from 'enzyme'

import { TableModal } from 'Common'
import { updateInput } from 'utilities/test-utils'

const onSelect = jest.fn()
const onClose = jest.fn()
const setPage = jest.fn()
const onSearch = jest.fn()

const cells = [
  { title: 'Name', propName: 'name' }
]

const defaultProps = {
  title: 'My Table',
  selectedItem: null,
  pageItems: undefined,
  itemsCount: 0,
  onSelect,
  onClose,
  cells,
  isOpen: undefined,
  isLoading: undefined,
  page: 0,
  setPage,
  perPage: undefined,
  onSearch,
  searchPlaceholder: undefined,
  sortBy: { index: 1, direction: 'desc' }
} as const

const mountWrapper = (props) => mount(<TableModal {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should be hidden by default', () => {
  const wrapper = mountWrapper({ isOpen: undefined })
  expect(wrapper.html()).toBe('')
})

describe('when is open', () => {
  const props = { ...defaultProps, isOpen: true } as const

  it('should be closeable', () => {
    const wrapper = mountWrapper(props)
    wrapper.find('button[aria-label="Close"]').simulate('click')
    expect(onClose).toHaveBeenCalledTimes(1)
  })

  it('should be cancelable', () => {
    const wrapper = mountWrapper(props)
    wrapper.find('button[data-testid="cancel"]').simulate('click')
    expect(onClose).toHaveBeenCalledTimes(1)
  })

  it('should be filterable', () => {
    const wrapper = mountWrapper(props)
    const searchInput = wrapper.find('.pf-c-toolbar').at(0).find('input[type="search"]')
    const searchButton = wrapper.find('.pf-c-toolbar').at(0).find('button[data-testid="search"]')

    expect(searchInput.prop('disabled')).toBe(false)
    expect(searchButton.prop('disabled')).toBe(false)

    updateInput(wrapper, 'foo', searchInput)
    searchButton.simulate('click')

    expect(onSearch).toHaveBeenCalledWith('foo')
  })

  it('should have a search placeholder', () => {
    const searchPlaceholder = 'Find Waldo'
    const wrapper = mountWrapper({ ...props, searchPlaceholder })

    const searchInput = wrapper.find('.pf-c-toolbar').at(0).find('input[type="search"]')
    expect(searchInput.props().placeholder).toEqual(searchPlaceholder)
  })

  describe('when collection empty', () => {
    beforeAll(() => {
      props.pageItems = []
    })

    it('should render an empty message', () => {
      const wrapper = mountWrapper(props)
      expect(wrapper.find('NoMatchFound').exists()).toBe(true)
    })
  })

  describe('when there are items', () => {
    const collection = new Array(11).fill({}).map((_, j) => ({ id: j, name: `Item ${j}` }))
    const perPage = 10

    beforeAll(() => {
      props.perPage = perPage
      props.pageItems = collection.slice(0, perPage)
    })

    it('should render a table filled with items', () => {
      const wrapper = mountWrapper(props)

      const rows = wrapper.find('tbody tr')
      expect(rows.length).toEqual(perPage)

      cells.forEach(({ title, propName }) => {
        expect(rows.at(0).find(`td[data-label="${title}"]`).text()).toEqual(collection[0][propName])
      })
    })

    it('should have pagination', () => {
      const wrapper = mountWrapper({ ...props, page: 1, itemsCount: collection.length })
      const button = wrapper.find('.pf-c-pagination button[data-action="next"]').at(0)
      button.simulate('click')
      expect(setPage).toHaveBeenCalledWith(2)
    })

    describe('when no item is yet selected', () => {
      beforeAll(() => {
        props.selectedItem = null
      })

      it('should enable select button after an item is picked', () => {
        const wrapper = mountWrapper(props)
        expect(wrapper.find('button[data-testid="select"]').prop('disabled')).toBe(true)

        const radio = wrapper.find('tbody tr').first().find('input')
        radio.simulate('change', { currentTarget: { checked: true } })

        expect(wrapper.find('button[data-testid="select"]').prop('disabled')).toBe(false)
      })
    })

    describe('when an item is already selected', () => {
      const selectedItem = collection[5]

      beforeAll(() => {
        props.selectedItem = selectedItem;
      })

      it('should not disable select button', () => {
        const wrapper = mountWrapper(props)
        expect(wrapper.find('button[data-testid="select"]').prop('disabled')).toBe(false)
      })

      it('should be able to select an item', () => {
        const wrapper = mountWrapper(props)
        wrapper.find('button[data-testid="select"]').simulate('click')
        expect(onSelect).toHaveBeenCalledWith(selectedItem)
      })
    })
  })
})
