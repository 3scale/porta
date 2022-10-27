import { useEffect, useRef, useState } from 'react'
import {
  Button,
  ButtonVariant,
  Form,
  InputGroup,
  Popover,
  TextInput
} from '@patternfly/react-core'
import { SearchIcon } from '@patternfly/react-icons'
import { createReactWrapper } from 'utilities/createReactWrapper'

import './ToolbarSearch.scss'

type Props = {
  placeholder: string,
  name?: string,
  children?: React.ReactNode
}

const FORM_ID = 'toolbar-search-form'
const INPUT_NAME_QUERY = 'search[query]'
const INPUT_NAME_UTF8 = 'utf8'

const ToolbarSearch: React.FunctionComponent<Props> = ({
  placeholder,
  name = INPUT_NAME_QUERY,
  children
}) => {
  // const query = new URL(window.location).searchParams.get(name) TODO: check this is the same
  const query = new URL(window.location.toString()).searchParams.get(name)
  const [searchText, setSearchText] = useState<string>(query || '')
  const [showPopover, setShowPopover] = useState<boolean>(false)

  const inputRef = useRef<HTMLInputElement>()

  useEffect(() => {
    const input = inputRef.current
    input?.addEventListener('search', handleOnSearch)

    return () => input?.removeEventListener('search', handleOnSearch)
  }, [])

  useEffect(() => {
    if (showPopover) {
      setShowPopover(false)
    }
  }, [searchText])

  const onSubmitSearch = (value: string) => {
    const form = document.forms.namedItem(FORM_ID) as HTMLFormElement

    const inputClearedBeforeAnySearch = !query && value.length === 0
    const inputCleared = value.length === 0
    const searchTextTooShortForSphinx = value.length < 3

    if (inputClearedBeforeAnySearch) {
      return
    } else if (inputCleared) {
      removeEmptySearchQueryFromURL(form)
    } else if (searchTextTooShortForSphinx) {
      setShowPopover(true)
      return
    }

    form.submit()
  }

  const removeEmptySearchQueryFromURL = (form: HTMLFormElement) => {
    (form.elements.namedItem(name) as Element).removeAttribute('name');
    (form.elements.namedItem(INPUT_NAME_UTF8) as Element).removeAttribute('name')
  }

  const handleOnSearch: EventListener = (e: Event) => {
    e.preventDefault()
    onSubmitSearch((e.currentTarget as HTMLInputElement).value)
  }

  const Popopover: any = Popover // HACK: remove this after upgrading @patternfly/react-core

  return (
    <Form
      acceptCharset="UTF-8"
      id={FORM_ID}
      method="get"
      role="search"
      onSubmit={e => e.preventDefault()}
    >
      <InputGroup>
        <input name={INPUT_NAME_UTF8} type="hidden" value="✓" />
        {children}
        <TextInput
          // HACK: remove this ugly casting after upgrading to @patternfly/react-core 4
          aria-label="Search"
          autoComplete="off"
          name={name}
          placeholder={placeholder}
          ref={inputRef as unknown as React.Ref<HTMLInputElement> | undefined}
          type="search"
          value={searchText}
          onChange={setSearchText}
        />
        <Popopover
          aria-label="search minimum length"
          bodyContent={<div>To search, type at least 3 characters.</div>}
          isVisible={showPopover}
          shouldClose={() => setShowPopover(false)}
        >
          <Button
            aria-label="search button for search input"
            variant={ButtonVariant.control}
            onClick={() => onSubmitSearch(searchText)}
          >
            <SearchIcon />
          </Button>
        </Popopover>
      </InputGroup>
    </Form>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const ToolbarSearchWrapper = (props: Props, containerId: string): void => createReactWrapper(<ToolbarSearch {...props} />, containerId)

export { ToolbarSearch, ToolbarSearchWrapper, Props }
