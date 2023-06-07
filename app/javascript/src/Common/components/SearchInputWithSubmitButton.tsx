import { useEffect, useState } from 'react'
import {
  Popover,
  SearchInput
} from '@patternfly/react-core'

import { createReactWrapper } from 'utilities/createReactWrapper'

interface Props {
  placeholder: string;
  name?: string;
}

const INPUT_NAME_QUERY = 'search[query]'
const INPUT_NAME_UTF8 = 'utf8'

const SearchInputWithSubmitButton: React.FunctionComponent<Props> = ({
  placeholder,
  name = INPUT_NAME_QUERY
}) => {
  const query = new URL(window.location.href).searchParams.get(name)
  const url = new URL(window.location.href)
  const [searchText, setSearchText] = useState<string>(query ?? '')
  const [showPopover, setShowPopover] = useState<boolean>(false)

  useEffect(() => {
    if (showPopover) {
      setShowPopover(false)
    }
  }, [searchText])

  const onSubmitSearch = (value: string) => {
    url.searchParams.set(INPUT_NAME_UTF8, '✓')
    url.searchParams.set(name, value)
    window.location.replace(url.toString())
  }

  const onSearch = () => {
    const searchTextTooShortForSphinx = searchText.length < 3

    if (searchTextTooShortForSphinx) {
      setShowPopover(true)
      return
    }

    onSubmitSearch(searchText)
  }

  const onClear = () => {
    const inputClearedBeforeAnySearch = !query

    if (inputClearedBeforeAnySearch) {
      setSearchText('')
    } else {
      onSubmitSearch('')
    }
  }

  return (
    <Popover
      aria-label="search minimum length"
      bodyContent={<div>To search, type at least 3 characters</div>}
      isVisible={showPopover}
      shouldClose={() => { setShowPopover(false) }}
    >
      <SearchInput
        placeholder={placeholder}
        value={searchText}
        onChange={(_event, value) => { setSearchText(value) }}
        onClear={onClear}
        onSearch={onSearch}
      />
    </Popover>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const SearchInputWithSubmitButtonWrapper = (props: Props, containerId: string): void => { createReactWrapper(<SearchInputWithSubmitButton {...props} />, containerId) }

export type { Props }
export { SearchInputWithSubmitButton, SearchInputWithSubmitButtonWrapper }
