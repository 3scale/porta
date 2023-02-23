import { mount } from 'enzyme'

import { openSelectWithModal as openModal, waitForPromises } from 'utilities/test-utils'
import { SelectWithModal } from 'Common/components/SelectWithModal'
import { TableModal } from 'Common/components/TableModal'

import type { Props } from 'Common/components/SelectWithModal'
import type { IRecord } from 'Types'

const onSelect = jest.fn()
const fetchItems = jest.fn()

type CrewMember = IRecord & { role: string }

const cells = [
  { propName: 'name', title: 'Name' },
  { propName: 'role', title: 'Role' }
] as Props<CrewMember>['cells']

const items = [
  { id: 0, name: 'J. Holden', role: 'Captain' },
  { id: 1, name: 'N. Nagata', role: 'Engineer' },
  { id: 2, name: 'A. Kamal', role: 'Pilot' }
]

const title = 'Select a crew member'

const defaultProps: Props<CrewMember> = {
  label: 'Label',
  id: 'id',
  name: 'name',
  item: null,
  items,
  itemsCount: items.length,
  cells,
  onSelect,
  header: 'Header',
  isDisabled: undefined,
  title,
  placeholder: 'Placeholder',
  searchPlaceholder: undefined,
  footerLabel: 'Footer Label',
  fetchItems
}

const mountWrapper = (props: Partial<Props<CrewMember>> = {}) => mount(<SelectWithModal {...{ ...defaultProps, ...props }} />)

beforeEach(() => jest.resetAllMocks())

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toEqual(true)
})

it('should be able to select an item', () => {
  const targetItem = items[0]
  const wrapper = mountWrapper()

  wrapper.find('.pf-c-select__toggle-button').simulate('click')
  wrapper.find('.pf-c-select__menu li button').filterWhere(n => n.text().includes(targetItem.name)).simulate('click')

  expect(onSelect).toHaveBeenCalledWith(targetItem)
})

describe('with 20 items or less', () => {
  const items: CrewMember[] = new Array(20).fill({}).map((_i, j) => ({ id: j, name: `Mr. ${j}`, role: String(j) }))
  const props = {
    items,
    itemsCount: items.length
  }

  it('should display all items and a title, but no sticky footer', () => {
    const wrapper = mountWrapper(props)
    wrapper.find('.pf-c-select__toggle-button').simulate('click')
    expect(wrapper.find('.pf-c-select__menu li').length).toEqual(items.length + 1)
  })

  it('should not be able to show a modal', () => {
    const wrapper = mountWrapper(props)
    expect(wrapper.exists(TableModal)).toEqual(false)
  })
})

describe('with more than 20 items', () => {
  const items: CrewMember[] = new Array(25).fill({}).map((i, j) => ({ id: j, name: `Mr. ${j}`, role: String(j) }))
  const props = {
    items,
    itemsCount: items.length
  }

  it('should display up to 20 items, a title and a sticky footer', () => {
    const wrapper = mountWrapper(props)
    wrapper.find('.pf-c-select__toggle-button').simulate('click')
    expect(wrapper.find('.pf-c-select__menu li')).toHaveLength(22)
  })

  it('should be able to show a modal', () => {
    const wrapper = mountWrapper(props)

    expect(wrapper.find(TableModal).props().isOpen).toEqual(false)

    openModal(wrapper)
    expect(wrapper.find(TableModal).props().isOpen).toEqual(true)
    expect(onSelect).toHaveBeenCalledTimes(0)
  })

  it('should be able to select an option from the modal', () => {
    const wrapper = mountWrapper(props)

    openModal(wrapper)
    wrapper.find('input[type="radio"]').first().simulate('change', { value: true })
    wrapper.find('button[data-testid="select"]').simulate('click')

    expect(onSelect).toHaveBeenCalledWith(items[0])
  })

  it('should display all columns in the modal', () => {
    const wrapper = mountWrapper(props)

    openModal(wrapper)
    const ths = wrapper.find('table th')

    expect(cells.every(c => ths.exists(`[data-label="${c.title}"]`))).toEqual(true)
  })

  // FIXME: simulate change
  it.todo('should be able to search an item by name')
  //   const wrapper = mountWrapper(props)

  //   openModal(wrapper)
  //   wrapper.find('input[type="search"]').simulate('change', { value: 'pepe' })
  //   expect(fetchItems).toHaveBeenCalledTimes(1)
  //   expect(fetchItems).toHaveBeenCalledWith(expect.objectContaining({ query: 'pepe' }))
  // })

  // FIXME: simulate change not working, also this might be tricky to implement
  it.todo('should not clear search input after closing modal')

  describe('when there are remote items that have not been fetched', () => {
    const props = {
      items: [],
      itemsCount: 30
    }

    it('should fetch more items', async () => {
      const perPage = 5
      const fetchedItems = items.slice(0, perPage)
      fetchItems.mockResolvedValue({ items: fetchedItems, count: props.itemsCount })

      const wrapper = mountWrapper(props)
      openModal(wrapper)

      expect(fetchItems).toHaveBeenCalledTimes(1)
      expect(fetchItems).toHaveBeenCalledWith({ page: 1, perPage })

      await waitForPromises(wrapper)
      const modal = wrapper.find('TableModal')
      expect(modal.prop('page')).toEqual(1)
      expect(modal.prop('itemsCount')).toEqual(props.itemsCount)
      expect(modal.prop('pageItems')).toEqual(fetchedItems)
    })
  })
})

describe('with no items', () => {
  const props = {
    items: [],
    itemsCount: 0
  }

  it('should show an empty message that is disabled', () => {
    const wrapper = mountWrapper(props)
    wrapper.find('.pf-c-select__toggle-button').simulate('click')

    const items = wrapper.find('SelectOption')
    expect(items.length).toEqual(2)

    const emptyItem = items.last()
    expect(emptyItem.prop('isDisabled')).toEqual(true)
    expect(emptyItem.text()).toEqual('No results found')
  })
})
