import { useEffect, useRef, useState } from 'react'
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

const SearchInputWithSubmitButton: React.FunctionComponent<Props> = ({
  placeholder,
  name = INPUT_NAME_QUERY
}) => {
  const query = new URL(window.location.href).searchParams.get(name)
  const url = new URL(window.location.href)
  const [searchText, setSearchText] = useState<string>(query ?? '')
  const [showPopover, setShowPopover] = useState<boolean>(false)

  const inputRef = useRef<HTMLInputElement>()

  const onSubmitSearch = (value: string) => {
    const searchTextTooShortForSphinx = value.length < 3

    if (searchTextTooShortForSphinx) {
      setShowPopover(true)
      return
    }

    url.searchParams.set(name, value)
    window.location.replace(url.toString())
  }

  const onClearSearch = () => {
    url.searchParams.delete(name)
    window.location.replace(url.toString())
  }

  useEffect(() => {
    if (showPopover) {
      setShowPopover(false)
    }
  }, [searchText])

  return (
    <Popover
      aria-label="search minimum length"
      bodyContent={<div>To search, type at least 3 characters</div>}
      isVisible={showPopover}
      shouldClose={() => { setShowPopover(false) }}
    >
      <SearchInput
        placeholder={placeholder}
        ref={inputRef as unknown as React.Ref<HTMLInputElement> | undefined}
        value={searchText}
        onChange={(_event, value) => { setSearchText(value) }}
        onClear={() => { onClearSearch() }}
        onSearch={(_event, value) => { onSubmitSearch(value) }}
      />
    </Popover>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const SearchInputWithSubmitButtonWrapper = (props: Props, containerId: string): void => { createReactWrapper(<SearchInputWithSubmitButton {...props} />, containerId) }

export type { Props }
export { SearchInputWithSubmitButton, SearchInputWithSubmitButtonWrapper }
