import { useEffect, useMemo, useRef, useState } from 'react'
import { SortByDirection, sortable } from '@patternfly/react-table'
import escapeRegExp from 'lodash.escaperegexp'
import { Button } from '@patternfly/react-core'
import PlusCircle from '@patternfly/react-icons/dist/js/icons/plus-circle-icon'

import { TableModal } from 'Common/components/TableModal'
import { paginateCollection } from 'utilities/paginateCollection'
import { createReactWrapper } from 'utilities/createReactWrapper'
import { fetchPaginatedProducts as fetchItems } from 'NewApplication/data/Products'
import type { FetchPaginatedParams } from 'utilities/ajax'
import { fetchPaginated, patch } from 'utilities/ajax'
import { toast } from 'utilities/toast'
import { Exception } from 'SiteEmails/components/Exception'
import { useConfirmToLeave } from 'utilities/useConfirmToLeave'

import type { RefObject } from 'react'
import type { Product } from 'SiteEmails/types'
import type { Props as SelectWithModalProps } from 'Common/components/SelectWithModal'

interface Props {
  buttonLabel: string;
  products: Product[];
  exceptions: Product[];
  productsCount: number;
  productsPath?: string;
  removeConfirmation: string;
  searchPlaceholder?: string;
}

const PER_PAGE = 5

const CustomSupportEmails: React.FunctionComponent<Props> = ({
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

  const [exceptions, setExceptions] = useState<Product[]>(initialExceptions)
  const [exceptionBeingEdited, setExceptionBeingEdited] = useState<Product | undefined>()
  const [isEditLoading, setIsEditLoading] = useState(false)
  const [editError, setEditError] = useState<string | undefined>()
  const [isRemoveLoading, setIsRemoveLoading] = useState(false)

  const [exceptionBeingAdded, setExceptionBeingAdded] = useState<Product | undefined>()

  // Memos
  const unsavedChanges = useMemo(
    () => exceptionBeingAdded !== undefined || exceptionBeingEdited !== undefined,
    [exceptionBeingAdded, exceptionBeingEdited]
  )

  // Sort by name ASC, see Sites::EmailsController#props
  const sortBy = { index: 1, direction: SortByDirection.asc } as const

  const handleOnModalSelect = (selected: Product | null) => {
    setModalOpen(false)
    // FIXME: search input is cleared on modal close even though the items are filtered. This is a
    // bit confusing, however resetting the search results would require a new request that would be
    // ineffectual.

    if (selected) {
      setExceptionBeingAdded(selected)
      setExceptionBeingEdited(selected)
      setExceptions([...exceptions, selected])
    }
  }

  // Fetch new items when navigating to an empty page
  useEffect(() => {
    if (!modalOpen || !productsPath) {
      return
    }

    const pageItems = pageDictionary[page]
    const pageIsEmpty = pageItems === undefined || pageItems.length === 0
    const thereAreMoreItems = productsCount > (page - 1) * PER_PAGE

    if (pageIsEmpty && thereAreMoreItems) {
      setIsLoading(true)

      // eslint-disable-next-line @typescript-eslint/naming-convention
      const params: FetchPaginatedParams = { page, perPage: PER_PAGE, compact: 'true', without_support_emails: 'true' }

      fetchPaginated<Product>(productsPath, params)
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

  // Fetch items based on query search
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

  useConfirmToLeave(unsavedChanges)

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

  const handleOnEdit = (exception: Product, ref: RefObject<HTMLInputElement>) => {
    setExceptionBeingEdited(exception)
    ref.current?.focus()
  }

  const saveEdit = (ref: RefObject<HTMLInputElement>) => {
    if (!exceptionBeingEdited) {
      return
    }

    const { id } = exceptionBeingEdited
    const input = ref.current

    if (!input) {
      return
    }

    const { value } = input

    if (exceptionBeingEdited.supportEmail === value) {
      setExceptionBeingEdited(undefined)
      setEditError(undefined)
      return
    }

    if (!input.checkValidity()) {
      input.reportValidity()
      return
    }

    // eslint-disable-next-line @typescript-eslint/naming-convention
    const body = { service: { support_email: value } }

    setIsEditLoading(true)
    void patch(`/apiconfig/services/${id}`, body)
      .then(({ success, message }) => {
        if (success) {
          toast(message, 'success')
          setExceptionBeingEdited(undefined)
          setEditError(undefined)
          if (exceptionBeingAdded) {
            setExceptionBeingAdded(undefined)
          } else {
            const newExceptions = exceptions.map(e => {
              if (e.id === id) {
                e.supportEmail = value
              }
              return e
            })
            setExceptions(newExceptions)
          }
        } else {
          toast(message, 'danger')
          setEditError('')
        }
      })
      .finally(() => {
        setIsEditLoading(false)
      })
  }

  const cancelEdit = (ref: RefObject<HTMLInputElement>) => {
    if (!exceptionBeingEdited) {
      return
    }

    if (exceptionBeingAdded) {
      setExceptionBeingAdded(undefined)
      setExceptions([...exceptions.slice(0, -1)])
    } else {
      const { supportEmail } = exceptionBeingEdited
      const input = ref.current
      if (input) {
        input.value = supportEmail
      }
    }

    setExceptionBeingEdited(undefined)
    setEditError(undefined)
  }

  const handleOnRemove = (id: number) => {
    if (window.confirm(removeConfirmation)) {
      // eslint-disable-next-line @typescript-eslint/naming-convention
      const body = { service: { support_email: null } }

      setIsRemoveLoading(true)
      void patch(`/apiconfig/services/${id}`, body)
        .then(({ success, message }) => {
          if (success) {
            toast(message, 'success')
            setExceptions([...exceptions.slice(0, -1)])
          } else {
            toast(message, 'danger')
          }
        })
        .finally(() => {
          setIsRemoveLoading(false)
        })
    }
  }

  return (
    <>
      {exceptions.map(exception => (
        <Exception
          key={exception.id}
          isBeingEdited={exception === exceptionBeingEdited}
          isEditLoading={isEditLoading}
          isEditable={exceptionBeingEdited === undefined && exceptionBeingAdded === undefined && !isRemoveLoading}
          product={exception}
          validated={exception === exceptionBeingEdited && editError !== undefined ? 'error' : undefined}
          onCancel={cancelEdit}
          onEdit={handleOnEdit}
          onRemove={handleOnRemove}
          onSave={saveEdit}
        />
      ))}

      <Button
        isInline
        icon={<PlusCircle />}
        isDisabled={unsavedChanges}
        variant="link"
        onClick={() => { setModalOpen(true) }}
      >
        {buttonLabel}
      </Button>

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
const CustomSupportEmailsWrapper = (props: Props, containerId: string): void => { createReactWrapper(<CustomSupportEmails {...props} />, containerId) }

export type { Props }
export { CustomSupportEmails, CustomSupportEmailsWrapper }
