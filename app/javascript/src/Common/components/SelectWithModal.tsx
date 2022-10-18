import { useEffect, useState } from 'react'
import { SortByDirection } from '@patternfly/react-table'
import { FancySelect } from 'Common/components/FancySelect'
import { TableModal } from 'Common/components/TableModal'
import { paginateCollection } from 'utilities/paginateCollection'
import escapeRegExp from 'lodash.escaperegexp'

import type { Record } from 'utilities/patternfly-utils'
import type { ITransform } from '@patternfly/react-table'
import type { FetchItemsRequestParams, FetchItemsResponse } from 'utilities/ajax'

import './SelectWithModal.scss'

type Props<T extends Record> = {
  label: string,
  id: string,
  name: string,
  item: T | null,
  items: T[],
  itemsCount: number,
  cells: Array<{ title: string, propName: keyof T, transforms?: ITransform[] }>,
  onSelect: (t: T | null) => void,
  header: string,
  isDisabled?: boolean,
  title: string,
  placeholder: string,
  searchPlaceholder?: string,
  footerLabel: string,
  helperTextInvalid?: string,
  fetchItems?: (params: FetchItemsRequestParams) => FetchItemsResponse<T>
}

const PER_PAGE = 5
const MAX_ITEMS = 20

const SelectWithModal = <T extends Record>({
  label,
  id,
  name,
  item,
  items: initialItems,
  itemsCount,
  cells,
  onSelect,
  header,
  isDisabled,
  title,
  placeholder,
  searchPlaceholder,
  footerLabel,
  helperTextInvalid,
  fetchItems
}: Props<T>): React.ReactElement => {
  const [count, setCount] = useState(itemsCount)
  const [isLoading, setIsLoading] = useState(false)
  const [modalOpen, setModalOpen] = useState(false)
  const [page, setPage] = useState(1)
  const [isOnMount, setIsOnMount] = useState(true)
  const [query, setQuery] = useState('')
  const [pageDictionary, setPageDictionary] = useState(() => paginateCollection(initialItems, PER_PAGE))

  const shouldHaveModal = itemsCount > MAX_ITEMS

  // TODO: Implement sorting by means of fetchItems, right now it's fixed
  const sortBy = { index: 3, direction: SortByDirection.desc } as const

  const handleOnFooterClick = () => {
    setModalOpen(true)
  }

  const handleOnModalSelect = (selected: null | T) => {
    setModalOpen(false)
    onSelect(selected)
    // FIXME: search input is cleared on modal close even though the items are filtered. This is a bit confusing,
    // however resetting the search results would require a new request that would be ineffectual
  }

  useEffect(() => {
    if (!shouldHaveModal || !modalOpen || !fetchItems) {
      return
    }

    const pageItems = pageDictionary[page]
    const pageIsEmpty = pageItems === undefined || pageItems.length === 0
    const thereAreMoreItems = itemsCount > (page - 1) * PER_PAGE

    if (pageIsEmpty && thereAreMoreItems) {
      setIsLoading(true)

      fetchItems({ page, perPage: PER_PAGE })
        .then(({ items: newItems, count }) => {
          setPageDictionary({ ...pageDictionary, [page]: newItems })
          setCount(count)
        })
        .finally(() => setIsLoading(false))
    }
  }, [page, shouldHaveModal, modalOpen])

  useEffect(() => {
    if (!fetchItems) {
      return
    }

    if (isOnMount) {
      setIsOnMount(false)
    } else {
      fetchItems({ page: 1, perPage: 20, query }) // perPage 20 to get 4 pages
        .then(({ items: fetchedItems, count }) => setSearchResults(fetchedItems, count))
    }
  }, [query])

  const setSearchResults = (items: T[], count: number) => {
    setPageDictionary(paginateCollection(items, PER_PAGE))
    setCount(count)
    setPage(1)
  }

  const handleModalOnSetPage = (page: number) => {
    setPage(page)
  }

  const handleOnModalClose = () => {
    setModalOpen(false)
    // TODO: abort any ongoing request? (using signal).
    // This makes the component much more complex and it might not worth it.
  }

  const onLocalSearch = (value: string) => {
    const term = new RegExp(escapeRegExp(value), 'i')
    const filteredItems = value !== '' ? initialItems.filter(b => term.test(b.name)) : initialItems
    setSearchResults(filteredItems, filteredItems.length)
  }

  return (
    <>
      <FancySelect
        footer={shouldHaveModal ? {
          label: footerLabel,
          onClick: handleOnFooterClick
        } : undefined}
        header={header}
        helperTextInvalid={helperTextInvalid}
        id={id}
        isDisabled={isDisabled}
        item={item || undefined}
        items={initialItems.slice(0, MAX_ITEMS)}
        label={label}
        name={name}
        placeholderText={placeholder}
        onSelect={onSelect}
      />

      {shouldHaveModal && (
        <TableModal
          cells={cells}
          isLoading={isLoading}
          isOpen={modalOpen}
          itemsCount={count}
          page={page}
          pageItems={pageDictionary[page]}
          searchPlaceholder={searchPlaceholder}
          selectedItem={item}
          setPage={handleModalOnSetPage}
          sortBy={sortBy}
          title={title}
          onClose={handleOnModalClose}
          onSearch={fetchItems ? setQuery : onLocalSearch}
          onSelect={handleOnModalSelect}
        />
      )}
    </>
  )
}

export { SelectWithModal, Props }
