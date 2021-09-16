// @flow

import * as React from 'react'
import { useState, useEffect } from 'react'

import { SortByDirection, sortable } from '@patternfly/react-table'
import escapeRegExp from 'lodash.escaperegexp'
import { FancySelect, PaginatedTableModal } from 'Common'
import { paginateCollection, ajaxAbort } from 'utilities'

import type { Record } from 'utilities'
import type { FetchItemsRequestParams, FetchItemsResponse } from 'Types'

import './SelectWithModal.scss'

type Props<T: Record> = {
  label: string,
  fieldId: string,
  id: string,
  name: string,
  item: T | null,
  items: Array<T>,
  itemsCount: number,
  cells: Array<{ title: string, propName: string, transforms?: [typeof sortable] }>,
  onSelect: (T | null) => void,
  header: string,
  isDisabled?: boolean,
  title: string,
  placeholder: string,
  footerLabel: string,
  fetchItems: (params: FetchItemsRequestParams) => FetchItemsResponse<T>
}

const PER_PAGE = 5
const MAX_ITEMS = 20

const SelectWithModal = <T: Record>({
  label,
  fieldId,
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
  footerLabel,
  fetchItems
}: Props<T>): React.Node => {
  const [count, setCount] = useState(itemsCount)
  const [isLoading, setIsLoading] = useState(false)
  const [modalOpen, setModalOpen] = useState(false)
  const [page, setPage] = useState(1)
  const [isOnMount, setIsOnMount] = useState(true)
  const [query, setQuery] = useState('')
  const [pageDictionary, setPageDictionary] = useState(() => paginateCollection(initialItems, PER_PAGE))

  const shouldHaveModal = itemsCount > MAX_ITEMS

  // TODO: Implement sorting by means of fetchItems, right now it's fixed
  const sortBy = { index: 3, direction: SortByDirection.desc }

  const handleOnFooterClick = () => {
    setModalOpen(true)
  }

  const handleOnModalSelect = (selected) => {
    setModalOpen(false)
    onSelect(selected)
    // FIXME: search input is cleared on modal close even though the items are filtered. This is a bit confusing,
    // however resetting the search results would require a new request that would be ineffectual
  }

  useEffect(() => {
    if (!shouldHaveModal || !modalOpen) {
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
    if (isOnMount) {
      setIsOnMount(false)
    } else {
      fetchItems({ page: 1, perPage: 20, query }) // perPage 20 to get 4 pages
        .then(({ items: fetchedItems, count }) => setSearchResults(fetchedItems, count))
    }
  }, [query])

  const setSearchResults = (items, count) => {
    setPageDictionary(paginateCollection(items, PER_PAGE))
    setCount(count)
    setPage(1)
  }

  const handleModalOnSetPage = (page: number) => {
    setPage(page)
  }

  const handleOnModalClose = () => {
    setModalOpen(false)
    ajaxAbort()
  }

  const onLocalSearch = (value: string) => {
    const term = new RegExp(escapeRegExp(value), 'i')
    const filteredItems = value !== '' ? initialItems.filter(b => term.test(b.name)) : initialItems
    setSearchResults(filteredItems, filteredItems.length)
  }

  return (
    <>
      <FancySelect
        label={label}
        fieldId={fieldId}
        id={id}
        name={name}
        item={item}
        items={initialItems.slice(0, MAX_ITEMS)}
        onSelect={onSelect}
        header={header}
        footer={shouldHaveModal ? {
          label: footerLabel,
          onClick: handleOnFooterClick
        } : undefined}
        isDisabled={isDisabled}
        placeholderText={placeholder}
      />

      {shouldHaveModal && (
        <PaginatedTableModal
          title={title}
          cells={cells}
          isOpen={modalOpen}
          isLoading={isLoading}
          selectedItem={item}
          pageItems={pageDictionary[page]}
          itemsCount={count}
          onSelect={handleOnModalSelect}
          onClose={handleOnModalClose}
          page={page}
          setPage={handleModalOnSetPage}
          onSearch={fetchItems ? setQuery : onLocalSearch}
          sortBy={sortBy}
        />
      )}
    </>
  )
}

export { SelectWithModal }
