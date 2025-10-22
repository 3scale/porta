import { useEffect, useRef, useState } from 'react'
import { SortByDirection, sortable } from '@patternfly/react-table'
import { Button } from '@patternfly/react-core'
import PlusCircle from '@patternfly/react-icons/dist/js/icons/plus-circle-icon'

import { TableModal } from 'Common/components/TableModal'
import { createReactWrapper } from 'utilities/createReactWrapper'
import { fetchPaginated, patch } from 'utilities/ajax'
import { toast } from 'utilities/toast'
import { Exception } from 'SiteEmails/components/Exception'
import { useConfirmToLeave } from 'utilities/useConfirmToLeave'
import { ModalTableCollection } from 'utilities/ModalTableCollection'

import type { FetchPaginatedParams } from 'utilities/ajax'
import type { RefObject } from 'react'
import type { Product } from 'SiteEmails/types'
import type { Props as SelectWithModalProps } from 'Common/components/SelectWithModal'

interface Props {
  buttonLabel: string;
  products: Product[];
  exceptions: Product[];
  productsCount: number;
  productsPath: string;
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
  const { current: paginatedCollection } = useRef(new ModalTableCollection(initialProducts))

  const [count, setCount] = useState(productsCount)
  const [isModalLoading, setIsModalLoading] = useState(false)
  const [modalOpen, setModalOpen] = useState(false)
  const [page, setPage] = useState(1)
  const [query, setQuery] = useState('')

  const [exceptions, setExceptions] = useState<Product[]>(initialExceptions)
  const [exceptionBeingEdited, setExceptionBeingEdited] = useState<Product | undefined>()
  const [isEditLoading, setIsEditLoading] = useState(false)
  const [editError, setEditError] = useState<'error' | undefined>()
  const [isRemoveLoading, setIsRemoveLoading] = useState(false)

  const isAddingNewException = exceptionBeingEdited?.supportEmail === undefined

  const unsavedChanges = exceptionBeingEdited !== undefined
  useConfirmToLeave(unsavedChanges)

  // Fetch new items when navigating to an empty page
  useEffect(() => {
    if (!modalOpen) {
      return
    }

    if (paginatedCollection.isPageEmpty(page)) {
      setIsModalLoading(true)

      // eslint-disable-next-line @typescript-eslint/naming-convention
      const params: FetchPaginatedParams = { compact: 'true', without_support_emails: '', page, perPage: PER_PAGE }
      if (query) {
        params.query = query
      }

      fetchPaginated<Product>(productsPath, params)
        .then(({ items: newItems, count: newCount }) => {
          paginatedCollection.set(page, newItems)
          setCount(newCount)
        })
        .catch(console.error)
        .finally(() => { setIsModalLoading(false) })
    }
  }, [page, modalOpen, query])

  const handleOnSearch = (newQuery: string) => {
    setQuery(newQuery)
    paginatedCollection.clear()
    setPage(1)
  }

  const cells: SelectWithModalProps<Product>['cells'] = [
    { title: 'Name', propName: 'name', transforms: [sortable] },
    { title: 'System Name', propName: 'systemName' },
    { title: 'Last updated', propName: 'updatedAt' }
  ]

  const handleOnEdit = (exception: Product, { current: input }: RefObject<HTMLInputElement>) => {
    setExceptionBeingEdited(exception)
    input?.focus()
  }

  const handleOnModalSelect = (selected: Product | null) => {
    setModalOpen(false)

    if (!selected) {
      return
    }

    setExceptionBeingEdited(selected)
    setExceptions([...exceptions, selected])
  }

  const saveEdit = ({ current: input }: RefObject<HTMLInputElement>) => {
    if (!exceptionBeingEdited || !input) {
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

    const { id } = exceptionBeingEdited

    setIsEditLoading(true)
    void patchSupportEmail(id, value)
      .then((success) => {
        if (success) {
          setExceptionBeingEdited(undefined)
          setEditError(undefined)
          setExceptions(exceptions.map(e => e.id === id ? { ...e, supportEmail: value } : e))

          if (isAddingNewException) {
            paginatedCollection.clear()
          }
        } else {
          setEditError('error')
        }
      })
      .finally(() => { setIsEditLoading(false) })
  }

  const cancelEdit = ({ current: input }: RefObject<HTMLInputElement>) => {
    if (!exceptionBeingEdited) {
      return
    }

    if (isAddingNewException) {
      setExceptions([...exceptions.slice(0, -1)])
    } else {
      if (input) {
        // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- Guarded by isAddingNewException
        input.value = exceptionBeingEdited.supportEmail!
      }
    }

    setExceptionBeingEdited(undefined)
    setEditError(undefined)
  }

  const handleOnRemove = (id: number) => {
    if (window.confirm(removeConfirmation)) {
      setIsRemoveLoading(true)
      void patchSupportEmail(id, null)
        .then((success) => {
          if (success) {
            setExceptions(exceptions.filter(e => e.id !== id))
          }
        })
        .finally(() => { setIsRemoveLoading(false) })
    }
  }

  const patchSupportEmail = (id: number, newEmail: string | null) => {
    // eslint-disable-next-line @typescript-eslint/naming-convention
    return patch(`/apiconfig/services/${id}/support_email`, { support_email: newEmail })
      .then(({ success, message }) => {
        if (success) {
          toast(message, 'success')
        } else {
          toast(message, 'danger')
        }
        return success
      })
  }

  return (
    <>
      {exceptions.map(exception => (
        <Exception
          key={exception.id}
          isBeingEdited={exception === exceptionBeingEdited}
          isEditLoading={isEditLoading}
          isEditable={exceptionBeingEdited === undefined && !isRemoveLoading}
          product={exception}
          validated={exception === exceptionBeingEdited ? editError : undefined}
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
        isLoading={isModalLoading}
        isOpen={modalOpen}
        itemsCount={count}
        page={page}
        pageItems={paginatedCollection.get(page)}
        searchPlaceholder={searchPlaceholder}
        searchQuery={query}
        selectedItem={null}
        setPage={setPage}
        sortBy={{ index: 1, direction: SortByDirection.asc }}
        title="Select a product"
        onClose={() => { setModalOpen(false) }}
        onSearch={handleOnSearch}
        onSelect={handleOnModalSelect}
      />
    </>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const CustomSupportEmailsWrapper = (props: Props, containerId: string): void => { createReactWrapper(<CustomSupportEmails {...props} />, containerId) }

export type { Props }
export { CustomSupportEmails, CustomSupportEmailsWrapper }
