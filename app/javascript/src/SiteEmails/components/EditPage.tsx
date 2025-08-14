import { useEffect, useRef, useState } from 'react'
import { SortByDirection, sortable } from '@patternfly/react-table'
import escapeRegExp from 'lodash.escaperegexp'
import { Button, FormGroup, InputGroup, InputGroupText, TextInput } from '@patternfly/react-core'
// import PlusCircle from '@patternfly/react-icons/dist/js/icons/plus-circle-icon'
import MinusCircle from '@patternfly/react-icons/dist/js/icons/minus-circle-icon'

import { TableModal } from 'Common/components/TableModal'
import { paginateCollection } from 'utilities/paginateCollection'
import { createReactWrapper } from 'utilities/createReactWrapper'
import { fetchPaginatedProducts as fetchItems } from 'NewApplication/data/Products'

import type { Product } from 'NewApplication/types'
import type { Props as SelectWithModalProps } from 'Common/components/SelectWithModal'

interface Props {
  // buttonLabel: string;
  initialProducts: Product[];
  productsCount: number;
  productsPath?: string;
  searchPlaceholder?: string;
}

const PER_PAGE = 5

const EditPage: React.FunctionComponent<Props> = ({
  // buttonLabel,
  initialProducts,
  productsCount,
  productsPath,
  searchPlaceholder
}) => {
  let { current: isOnMount } = useRef(true)

  const [count, setCount] = useState(productsCount)
  const [isLoading, setIsLoading] = useState(false)
  const [modalOpen, setModalOpen] = useState(false)
  const [page, setPage] = useState(1)
  const [query, setQuery] = useState('')
  const [pageDictionary, setPageDictionary] = useState(() => paginateCollection(initialProducts, PER_PAGE))
  const [exceptions, setExceptions] = useState<Product[]>([])

  // TODO: Implement sorting by means of fetchItems, right now it's fixed
  const sortBy = { index: 3, direction: SortByDirection.desc } as const

  const handleOnModalSelect = (selected: Product | null) => {
    setModalOpen(false)
    // FIXME: search input is cleared on modal close even though the items are filtered. This is a bit confusing,
    // however resetting the search results would require a new request that would be ineffectual

    if (selected) {
      setExceptions([...exceptions, selected])
    }
  }

  useEffect(() => {
    const addButton = document.getElementById('add-exception')

    if (!addButton) {
      throw new Error('Add an exception button is not in the DOM')
    }

    addButton.addEventListener('click', () => {
      setModalOpen(true)
    })
  })

  useEffect(() => {
    if (!modalOpen || !productsPath) {
      return
    }

    const pageItems = pageDictionary[page]
    const pageIsEmpty = pageItems === undefined || pageItems.length === 0
    const thereAreMoreItems = productsCount > (page - 1) * PER_PAGE

    if (pageIsEmpty && thereAreMoreItems) {
      setIsLoading(true)

      fetchItems(productsPath, { page, perPage: PER_PAGE })
        .then(({ items: newItems, count: newCount }) => {
          setPageDictionary({ ...pageDictionary, [page]: newItems })
          setCount(newCount)
        })
        .catch(() => {
          // TODO
        })
        .finally(() => { setIsLoading(false) })
    }
  }, [page, modalOpen])

  useEffect(() => {
    if (!productsPath) {
      return
    }

    if (isOnMount) {
      isOnMount = false
    } else {
      // perPage 20 to get 4 pages
      fetchItems(productsPath, { page: 1, perPage: 20, query })
        .then(({ items: fetchedItems, count: newCount }) => {
          setSearchResults(fetchedItems, newCount)
        })
        .catch(() => {
          // TODO
        })
    }
  }, [query])

  const setSearchResults = (items: Product[], newCount: number) => {
    setPageDictionary(paginateCollection(items, PER_PAGE))
    setCount(newCount)
    setPage(1)
  }

  const handleModalOnSetPage = (newPage: number) => {
    setPage(newPage)
  }

  const handleOnModalClose = () => {
    setModalOpen(false)
    // TODO: abort any ongoing request? (using signal).
    // This makes the component much more complex and it might not worth it.
  }

  const onLocalSearch = (value: string) => {
    const term = new RegExp(escapeRegExp(value), 'i')
    const filteredItems = value !== '' ? initialProducts.filter(b => term.test(b.name)) : initialProducts
    setSearchResults(filteredItems, filteredItems.length)
  }

  const cells: SelectWithModalProps<Product>['cells'] = [
    { title: 'Name', propName: 'name' },
    { title: 'System Name', propName: 'systemName' },
    { title: 'Last updated', propName: 'updatedAt', transforms: [sortable] }
  ]

  return (
    <>
      {exceptions.map(({ id, name }) => (
        <FormGroup key={id}>
          <InputGroup>
            <InputGroupText>
              {name}
            </InputGroupText>
            <TextInput
              isRequired
              aria-label={`Support email for product ${name}`}
              id={`account_service_${id}_support_email`}
              maxLength={255}
              name={`account[services][${id}][support_email]`}
              type="email"
            />
            <Button aria-label="Remove" icon={<MinusCircle />} variant="plain" />
          </InputGroup>
        </FormGroup>
      ))}

      <TableModal
        cells={cells}
        isLoading={isLoading}
        isOpen={modalOpen}
        itemsCount={count}
        page={page}
        pageItems={pageDictionary[page]}
        searchPlaceholder={searchPlaceholder}
        selectedItem={null}
        setPage={handleModalOnSetPage}
        sortBy={sortBy}
        title="Select a product"
        onClose={handleOnModalClose}
        onSearch={productsPath ? setQuery : onLocalSearch}
        onSelect={handleOnModalSelect}
      />
    </>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const EditPageWrapper = (props: Props, containerId: string): void => { createReactWrapper(<EditPage {...props} />, containerId) }

export type { Props }
export { EditPage, EditPageWrapper }
