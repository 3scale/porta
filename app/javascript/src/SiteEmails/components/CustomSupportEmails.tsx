import { useEffect, useRef, useState } from 'react'
import { SortByDirection, sortable } from '@patternfly/react-table'
import escapeRegExp from 'lodash.escaperegexp'
import {
  Button,
  FormGroup,
  InputGroup,
  InputGroupText,
  Spinner,
  TextInput
} from '@patternfly/react-core'
import PencilIcon from '@patternfly/react-icons/dist/js/icons/pencil-alt-icon'
import PlusCircle from '@patternfly/react-icons/dist/js/icons/plus-circle-icon'
import TrashIcon from '@patternfly/react-icons/dist/js/icons/trash-icon'
import CheckIcon from '@patternfly/react-icons/dist/js/icons/check-icon'
import TimesIcon from '@patternfly/react-icons/dist/js/icons/times-icon'

import { TableModal } from 'Common/components/TableModal'
import { paginateCollection } from 'utilities/paginateCollection'
import { createReactWrapper } from 'utilities/createReactWrapper'
import { fetchPaginatedProducts as fetchItems } from 'NewApplication/data/Products'
import { patch } from 'utilities/ajax'
import { toast } from 'utilities/toast'
import { InlineEdit, InlineEditAction, InlineEditGroup } from 'Common/components/InlineEdit'

import type { KeyboardEventHandler } from 'react'
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
  const [exceptionBeingEditted, setExceptionBeingEditted] = useState<Product | undefined>()
  const [isEditLoading, setIsEditLoading] = useState(false)
  const [editError, setEditError] = useState<string | undefined>()
  const [isRemoveLoading, setIsRemoveLoading] = useState(false)

  const [exceptionBeingAdded, setExceptionBeingAdded] = useState<Product | undefined>()

  // Sort by name ASC, see Sites::EmailsController#props
  const sortBy = { index: 1, direction: SortByDirection.asc } as const

  const handleOnModalSelect = (selected: Product | null) => {
    setModalOpen(false)
    // FIXME: search input is cleared on modal close even though the items are filtered. This is a
    // bit confusing, however resetting the search results would require a new request that would be
    // ineffectual.

    if (selected) {
      setExceptionBeingAdded(selected)
      setExceptionBeingEditted(selected)
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

  const beforeUnloadHandler = (e: Event) => { e.preventDefault() }

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

  const inputId = (id: number) => `account_service_${id}_support_email`

  const handleOnEdit = (exception: Product) => {
    setExceptionBeingEditted(exception)
    window.addEventListener('beforeunload', beforeUnloadHandler)
    const input = document.getElementById(inputId(exception.id)) as HTMLInputElement
    input.focus()
  }

  const saveEdit = () => {
    if (!exceptionBeingEditted) {
      return
    }

    const { id } = exceptionBeingEditted
    const input = document.getElementById(inputId(id)) as HTMLInputElement
    const { value } = input

    if (exceptionBeingEditted.supportEmail === value) {
      setExceptionBeingEditted(undefined)
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
          setExceptionBeingEditted(undefined)
          setEditError(undefined)
          if (exceptionBeingAdded) {
            setExceptionBeingAdded(undefined)
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

  const cancelEdit = () => {
    if (!exceptionBeingEditted) {
      return
    }

    if (exceptionBeingAdded) {
      setExceptionBeingAdded(undefined)
      setExceptions([...exceptions.slice(0, -1)])
    } else {
      const { id, supportEmail } = exceptionBeingEditted
      const input = document.getElementById(inputId(id)) as HTMLInputElement
      input.value = supportEmail
    }

    window.removeEventListener('beforeunload', beforeUnloadHandler)
    setExceptionBeingEditted(undefined)
    setEditError(undefined)
  }

  const handleOnRemove = ({ id }: Product) => {
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

  const saveOnEnter: KeyboardEventHandler = ({ key }) => {
    if (key === 'Enter') {
      saveEdit()
    }
  }

  return (
    <>
      {exceptions.map(exception => {
        const { id, name, supportEmail } = exception
        const isBeingEdited = exception === exceptionBeingEditted

        return (
          <FormGroup key={id}>
            <InputGroup>
              <InputGroupText>
                {name}
              </InputGroupText>
              <TextInput
                isRequired
                aria-label={`Support email for product ${name}`}
                autoComplete="off"
                defaultValue={supportEmail}
                id={inputId(id)}
                maxLength={255}
                readOnly={!isBeingEdited}
                type="email"
                validated={isBeingEdited && editError !== undefined ? 'error' : undefined}
                onKeyDown={saveOnEnter}
              />
              <InlineEdit>
                <InlineEditGroup>
                  {exceptionBeingEditted === exception ? (
                    <>
                      <InlineEditAction valid>
                        <Button
                          aria-label="Save"
                          icon={isEditLoading ? <Spinner size="md" /> : <CheckIcon />}
                          isDisabled={isEditLoading}
                          variant="plain"
                          onClick={saveEdit}
                        />
                      </InlineEditAction>
                      <InlineEditAction>
                        <Button
                          aria-label="Cancel"
                          icon={<TimesIcon />}
                          isDisabled={isEditLoading}
                          variant="plain"
                          onClick={cancelEdit}
                        />
                      </InlineEditAction>
                    </>
                  ) : (
                    <>
                      <InlineEditAction>
                        <Button
                          aria-label="Edit"
                          icon={<PencilIcon />}
                          isDisabled={isRemoveLoading || exceptionBeingEditted !== undefined}
                          variant="plain"
                          onClick={() => { handleOnEdit(exception) }}
                        />
                      </InlineEditAction>
                      <InlineEditAction>
                        <Button
                          aria-label="Remove"
                          icon={<TrashIcon />}
                          isDisabled={isRemoveLoading || exceptionBeingEditted !== undefined}
                          variant="plain"
                          onClick={() => { handleOnRemove(exception) }}
                        />
                      </InlineEditAction>
                    </>
                  )}
                </InlineEditGroup>
              </InlineEdit>
            </InputGroup>
          </FormGroup>
        )
      })}

      {buttonLabel && (
        <Button
          isInline
          icon={<PlusCircle />}
          isDisabled={exceptionBeingAdded !== undefined || exceptionBeingEditted !== undefined}
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
const CustomSupportEmailsWrapper = (props: Props, containerId: string): void => { createReactWrapper(<CustomSupportEmails {...props} />, containerId) }

export type { Props }
export { CustomSupportEmails, CustomSupportEmailsWrapper }
