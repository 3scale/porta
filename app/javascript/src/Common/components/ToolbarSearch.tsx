import * as React from 'react';

import {
  Button,
  ButtonVariant,
  Form,
  InputGroup,
  Popover,
  TextInput
} from '@patternfly/react-core'
import { SearchIcon } from '@patternfly/react-icons'

import { createReactWrapper } from 'utilities'

import './ToolbarSearch.scss'

type Props = {
  placeholder: string,
  name?: string,
  children?: React.ReactNode
};

const FORM_ID = 'toolbar-search-form'
const INPUT_NAME_QUERY = 'search[query]'
const INPUT_NAME_UTF8 = 'utf8'

const ToolbarSearch = (
  {
    placeholder,
    name = INPUT_NAME_QUERY,
    children,
  }: Props,
): React.ReactElement => {
  const query = new URL(window.location).searchParams.get(name)
  const [searchText, setSearchText] = React.useState<string>(query || '')
  const [showPopover, setShowPopover] = React.useState<boolean>(false)

  const inputRef = React.useRef()

  React.useEffect(() => {
    const input = inputRef.current
    if (input) input.addEventListener('search', handleOnSearch)

    return () => input.removeEventListener('search', handleOnSearch);
  }, [])

  React.useEffect(() => {
    if (showPopover) {
      setShowPopover(false)
    }
  }, [searchText])

  const onSubmitSearch = (value: string) => {
    const form: HTMLFormElement = document.forms[FORM_ID]

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
    form.elements[name].removeAttribute('name')
    form.elements[INPUT_NAME_UTF8].removeAttribute('name')
  }

  const handleOnSearch = (e: React.SyntheticEvent<HTMLInputElement>) => {
    e.preventDefault()
    onSubmitSearch(e.currentTarget.value)
  }

  return (
    <Form
      id={FORM_ID}
      acceptCharset="UTF-8"
      method="get"
      role="search"
      onSubmit={e => e.preventDefault()}
    >
      <InputGroup>
        <input name={INPUT_NAME_UTF8} type="hidden" value="✓" />
        {children}
        <TextInput
          // $FlowIgnore[incompatible-type] it's fine, really
          ref={inputRef}
          placeholder={placeholder}
          name={name}
          type="search"
          aria-label="Search"
          value={searchText}
          onChange={setSearchText}
          autoComplete="off"
        />
        <Popover
          aria-label="search minimum length"
          bodyContent={<div>To search, type at least 3 characters.</div>}
          isVisible={showPopover}
          shouldClose={() => setShowPopover(false)}
        >
          <Button
            variant={ButtonVariant.control}
            aria-label="search button for search input"
            onClick={() => onSubmitSearch(searchText)}
          >
            <SearchIcon />
          </Button>
        </Popover>
      </InputGroup>
    </Form>
  )
}

const ToolbarSearchWrapper = (props: Props, containerId: string): void => createReactWrapper(<ToolbarSearch {...props} />, containerId)

export { ToolbarSearch, ToolbarSearchWrapper }
