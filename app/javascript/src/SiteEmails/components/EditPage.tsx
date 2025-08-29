import { useEffect, useRef, useState } from 'react'
import { SortByDirection, sortable } from '@patternfly/react-table'
import escapeRegExp from 'lodash.escaperegexp'
import { Button, FormGroup, InputGroup, InputGroupText, TextInput } from '@patternfly/react-core'
import PlusCircle from '@patternfly/react-icons/dist/js/icons/plus-circle-icon'
import MinusCircle from '@patternfly/react-icons/dist/js/icons/minus-circle-icon'

import { TableModal } from 'Common/components/TableModal'
import { paginateCollection } from 'utilities/paginateCollection'
import { createReactWrapper } from 'utilities/createReactWrapper'
import { fetchPaginatedProducts as fetchItems } from 'NewApplication/data/Products'

import type { Product } from 'NewApplication/types'
import type { Props as SelectWithModalProps } from 'Common/components/SelectWithModal'

interface Props {
  buttonLabel?: string;
  products: Product[];
  exceptions: Product[];
  productsCount: number;
  productsPath?: string;
  removeConfirmation: string;
  searchPlaceholder?: string;
}

const PER_PAGE = 5

type Exception = Product & {
  toBeRemoved?: boolean;
}

const EditPage: React.FunctionComponent<Props> = ({
  buttonLabel,
  products: initialProducts,
  exceptions: initialExceptions,
  productsCount,
  productsPath,
  removeConfirmation,
  searchPlaceholder
}) => {
  const isOnMountRef = useRef(true)

  const [count, setCount] = useState(productsCount)
  const [isLoading, setIsLoading] = useState(false)
  const [modalOpen, setModalOpen] = useState(false)
  const [page, setPage] = useState(1)
  const [query, setQuery] = useState('')
  const [pageDictionary, setPageDictionary] = useState(() => paginateCollection(initialProducts, PER_PAGE))
  const [exceptions, setExceptions] = useState<Exception[]>(initialExceptions)

  // Sort by name ASC, see Sites::EmailsController#props
  const sortBy = { index: 1, direction: SortByDirection.asc } as const

  const handleOnModalSelect = (selected: Product | null) => {
    setModalOpen(false)
    // FIXME: search input is cleared on modal close even though the items are filtered. This is a
    // bit confusing, however resetting the search results would require a new request that would be
    // ineffectual.

    if (selected) {
      setExceptions([...exceptions, selected])
    }
  }

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

    if (isOnMountRef.current) {
      isOnMountRef.current = false
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

  // const beforeUnloadHandler = (e: Event) => { e.preventDefault() }

  // useEffect(() => {
  //   const anyChanges = exceptions.some(e => e.toBeRemoved ?? e.supportEmail === undefined)
  //   if (anyChanges && !window.onbeforeunload) {
  //     window.addEventListener('beforeunload', beforeUnloadHandler)
  //   } else {
  //     window.removeEventListener('beforeunload', beforeUnloadHandler)
  //   }
  // }, [exceptions])

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
    { title: 'Name', propName: 'name', transforms: [sortable] },
    { title: 'System Name', propName: 'systemName' },
    { title: 'Last updated', propName: 'updatedAt' }
  ]

  const handleOnRemove = (removedProduct: Product) => {
    if (!removedProduct.supportEmail) {
      setExceptions(exceptions.filter(e => e.id !== removedProduct.id))

    } else if (window.confirm(removeConfirmation)) {
      setExceptions(exceptions.map(e => {
        if (e.id === removedProduct.id) {
          return { ...removedProduct, toBeRemoved: true }
        } else {
          return e
        }
      }))
    }
  }

  return (
    <>
      {exceptions.map(exception => {
        const { id, name, supportEmail, toBeRemoved } = exception

        return (
          <FormGroup key={id} className={toBeRemoved ? 'to-be-removed' : undefined}>
            <InputGroup>
              <InputGroupText className={toBeRemoved ? 'pf-m-disabled' : undefined}>
                {name}
              </InputGroupText>
              <TextInput
                aria-label={`Support email for product ${name}`}
                defaultValue={supportEmail}
                id={`account_service_${id}_support_email`}
                maxLength={255}
                name={`account[services][${id}][${toBeRemoved ? 'remove' : 'support_email'}]`}
                readOnly={toBeRemoved}
                type="email"
              />
              <Button
                aria-label="Remove"
                icon={<MinusCircle />}
                variant="plain"
                onClick={() => { handleOnRemove(exception) }}
              />
            </InputGroup>
          </FormGroup>
        )
      })}

      {buttonLabel && (
        <Button
          isInline
          icon={<PlusCircle />}
          variant="link"
          onClick={() => { setModalOpen(true) }}
        >
          {buttonLabel}
        </Button>
      )}

      <TableModal
        cells={cells}
        disabledItems={exceptions}
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
