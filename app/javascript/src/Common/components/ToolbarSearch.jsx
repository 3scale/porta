// @flow

import * as React from 'react'

import {
  Button,
  ButtonVariant,
  Form,
  InputGroup,
  TextInput
} from '@patternfly/react-core'
import { SearchIcon } from '@patternfly/react-icons'

import { createReactWrapper } from 'utilities'

import './ToolbarSearch.scss'

type Props = {
  placeholder: string
}

const ToolbarSearch = ({ placeholder }: Props): React.Node => {
  const formId = 'toolbar-search-form'
  const query = new URL(window.location).searchParams.get('search[query]')
  const [searchText, setSearchText] = React.useState<string>(query || '')

  const ref = React.useRef()

  React.useEffect(() => {
    const input = ref.current
    if (input) input.addEventListener('search', handleOnSearch)

    // $FlowIgnore[incompatible-use] should not be null at this point
    return () => input.removeEventListener('search', handleOnSearch)
  }, [])

  const onSubmitSearch = (value: string) => {
    const form: HTMLFormElement = document.forms[formId]

    if (!query && value.length === 0) {
      return
    } else if (value.length === 0) {
      removeEmptySearchQueryFromURL(form)
    } else if (value.length < 3) {
      // Sphinx does not index less than 3 characters. Prevent form from being submitted.
      return
    }

    form.submit()
  }

  const removeEmptySearchQueryFromURL = (form: HTMLFormElement) => {
    form.elements['search[query]'].removeAttribute('name')
    form.elements['utf8'].removeAttribute('name')
  }

  const handleOnSearch = (e: SyntheticEvent<HTMLInputElement>) => {
    e.preventDefault()
    onSubmitSearch(e.currentTarget.value)
  }

  return (
    <Form
      id={formId}
      acceptCharset="UTF-8"
      method="get"
      role="search"
      onSubmit={e => e.preventDefault()}
    >
      <InputGroup>
        <input name="utf8" type="hidden" value="✓" />
        <TextInput
          // $FlowIgnore[incompatible-type] it's fine, really
          ref={ref}
          placeholder={placeholder}
          name="search[query]"
          type="search"
          aria-label="Search"
          value={searchText}
          onChange={setSearchText}
          autoComplete="off"
        />
        <Button
          variant={ButtonVariant.control}
          aria-label="search button for search input"
          isDisabled={searchText.length > 0 && searchText.length < 3}
          onClick={() => onSubmitSearch(searchText)}
        >
          <SearchIcon />
        </Button>
      </InputGroup>
    </Form>
  )
}

const ToolbarSearchWrapper = (props: Props, containerId: string): void => createReactWrapper(<ToolbarSearch {...props} />, containerId)

export { ToolbarSearch, ToolbarSearchWrapper }
