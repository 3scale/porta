import * as React from 'react'

import {
  Button,
  ButtonVariant,
  Form,
  InputGroup,
  Popover,
  TextInput
} from '@patternfly/react-core'
// import { Popover } from '@patternfly/react-core/dist/js/components/Popover/Popover.js'
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

const ToolbarSearch: React.FunctionComponent<Props> = ({
  placeholder,
  name = INPUT_NAME_QUERY,
  children
}) => {
  // const query = new URL(window.location).searchParams.get(name) TODO: check this is the same
  const query = new URL(window.location.toString()).searchParams.get(name)
  const [searchText, setSearchText] = React.useState<string>(query || '')
  const [showPopover, setShowPopover] = React.useState<boolean>(false)

  const inputRef = React.useRef<HTMLInputElement>()

  React.useEffect(() => {
    const input = inputRef.current
    input?.addEventListener('search', handleOnSearch)

    return () => input?.removeEventListener('search', handleOnSearch)
  }, [])

  React.useEffect(() => {
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
          // HACK: remove this ugly casting after upgrading to @patternfly/react-core 4
          ref={inputRef as unknown as React.Ref<HTMLInputElement> | undefined}
          placeholder={placeholder}
          name={name}
          type="search"
          aria-label="Search"
          value={searchText}
          onChange={setSearchText}
          autoComplete="off"
        />
        <Popopover
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
        </Popopover>
      </InputGroup>
    </Form>
  )
}

const ToolbarSearchWrapper = (props: Props, containerId: string): void => createReactWrapper(<ToolbarSearch {...props} />, containerId)

export { ToolbarSearch, ToolbarSearchWrapper, Props }
