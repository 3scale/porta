import { useEffect, useRef, useState } from 'react'
import {
  Button,
  InputGroup,
  TextInputGroup,
  TextInputGroupMain
} from '@patternfly/react-core'
import ArrowRightIcon from '@patternfly/react-icons/dist/js/icons/arrow-right-icon'
import SearchIcon from '@patternfly/react-icons/dist/js/icons/search-icon'
import TimesIcon from '@patternfly/react-icons/dist/js/icons/times-icon'

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
  const [isDisabled, setIsDisabled] = useState<boolean>(true)
  const [isSearchSubmitted, setIsSearchSubmitted] = useState<boolean>(false)

  const inputRef = useRef<HTMLInputElement>()

  const handleChange = (_event: React.FormEvent<HTMLInputElement>, value: string) => {
    setSearchText(value)
    setIsDisabled(value.length < 3)
  }

  const showClearButton = !!searchText

  const showUtilities = showClearButton

  const onClearSearch = ()  => {
    setSearchText('')
    if (isSearchSubmitted) {
      url.searchParams.delete(name)
      window.location.replace(url.toString())
      window.sessionStorage.setItem('search-submitted', 'false')
    }
    setIsSearchSubmitted(false)
  }

  const onSubmitSearch = (value: string) => {
    url.searchParams.set(name, value)
    window.location.replace(url.toString())
    window.sessionStorage.setItem('search-submitted', 'true')
  }

  useEffect(() => {
    if (window.sessionStorage.getItem('search-submitted') === 'true') {
      setIsSearchSubmitted(true)
    }
  }, [])

  return (
    <InputGroup>
      <TextInputGroup>
        <TextInputGroupMain
          icon={<SearchIcon />}
          placeholder={placeholder}
          ref={inputRef as unknown as React.Ref<HTMLInputElement> | undefined}
          value={searchText}
          onChange={handleChange}
        />
        {showUtilities && (
          <Button
            aria-label="Clear button and input"
            variant="plain"
            onClick={onClearSearch}
          >
            <TimesIcon />
          </Button>
        )}
      </TextInputGroup>
      <Button
        isDisabled={isDisabled}
        variant="control"
        onClick={() => { onSubmitSearch(searchText) }}
      >
        <ArrowRightIcon />
      </Button>
    </InputGroup>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const SearchInputWithSubmitButtonWrapper = (props: Props, containerId: string): void => { createReactWrapper(<SearchInputWithSubmitButton {...props} />, containerId) }

export type { Props }
export { SearchInputWithSubmitButton, SearchInputWithSubmitButtonWrapper }
