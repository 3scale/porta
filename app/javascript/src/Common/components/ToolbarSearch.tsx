import { useEffect, useState } from 'react'
import {
  Popover,
  SearchInput
} from '@patternfly/react-core'

import type { SearchInputProps } from '@patternfly/react-core'

interface Props extends SearchInputProps {
  onSubmitSearch?: (term: string) => void;
  searchQuery?: string;
}

const INPUT_NAME_QUERY = 'search[query]'
const INPUT_NAME_UTF8 = 'utf8'

const ToolbarSearch: React.FunctionComponent<Props> = ({
  name = INPUT_NAME_QUERY,
  onSubmitSearch,
  searchQuery,
  ...rest
}) => {
  const url = new URL(window.location.href)
  const query = searchQuery ?? url.searchParams.get(name)
  const [searchText, setSearchText] = useState<string>(query ?? '')
  const [showPopover, setShowPopover] = useState<boolean>(false)

  useEffect(() => {
    if (showPopover) {
      setShowPopover(false)
    }
  }, [searchText])

  const reloadWithQuery = (value: string) => {
    url.searchParams.delete('page')
    url.searchParams.set(INPUT_NAME_UTF8, '✓')
    url.searchParams.set(name, value)
    window.location.replace(url.toString())
  }

  const onSubmitSearchHandler = onSubmitSearch ?? reloadWithQuery

  const onSearch = () => {
    const searchTextTooShortForSphinx = searchText.length < 3

    if (searchTextTooShortForSphinx) {
      setShowPopover(true)
      return
    }

    onSubmitSearchHandler(searchText)
  }

  const onClear = () => {
    setSearchText('')

    // query is being cleared from a non-empty value
    if (query) {
      onSubmitSearchHandler('')
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
        value={searchText}
        onChange={(_event, value) => { setSearchText(value) }}
        onClear={onClear}
        onSearch={onSearch}
        // eslint-disable-next-line react/jsx-props-no-spreading -- SearchInput Props: node_modules/@patternfly/react-core/src/components/SearchInput/SearchInput.tsx
        {...rest}
      />
    </Popover>
  )
}

export type { Props }
export { ToolbarSearch }
