import { mount } from 'enzyme'

import { CompactListCard } from 'Common/components/CompactListCard'

import type { Props } from 'Common/components/CompactListCard'

const onSearch = jest.fn()
const setPage = jest.fn()
const searchInputRef: { current: HTMLInputElement | null } = { current: jest.fn() as unknown as HTMLInputElement }
const item = { name: 'Item Name', href: '/item/href', description: 'Item description' } as const
const defaultProps = {
  columns: ['Col A', 'Col B'],
  items: [item],
  searchInputRef,
  onSearch,
  page: 1,
  setPage,
  perPage: 5,
  searchInputPlaceholder: 'Search',
  tableAriaLabel: 'Table'
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<CompactListCard {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toEqual(true)
})

it('should not render a table header', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists('th')).toEqual(false)
})

it('should render each row with a link to the item overview page and a description', () => {
  const wrapper = mountWrapper()
  const rows = wrapper.find('table td')
  expect(rows.findWhere(n => n.text() === item.name).exists()).toEqual(true)
  expect(rows.exists(`a[href="${item.href}"]`)).toEqual(true)
  expect(rows.findWhere(n => n.text() === item.description).exists()).toEqual(true)
})

it('should trigger search when clicking the search button', () => {
  const wrapper = mountWrapper()

  wrapper.find('button[data-testid="search"]').simulate('click')
  expect(onSearch).toHaveBeenCalledTimes(1)
})
