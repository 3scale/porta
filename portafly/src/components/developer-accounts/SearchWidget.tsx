import React, { useState, useRef } from 'react'
import {
  SelectOption,
  Select,
  SelectVariant,
  InputGroup,
  TextInput,
  Button,
  ButtonVariant,
  SelectOptionObject
} from '@patternfly/react-core'
import { FilterIcon, SearchIcon } from '@patternfly/react-icons'
import { useTranslation } from 'i18n/useTranslation'
import { DataToolbarFilter, DataToolbarGroup } from '@patternfly/react-core/dist/js/experimental'

import './searchWidget.scss'

interface ISearch {
}

const SearchWidget: React.FunctionComponent<ISearch> = () => {
  const { t } = useTranslation('accounts')

  const group = t('accounts_table.col_group')
  const admin = t('accounts_table.col_admin')
  const state = t('accounts_table.col_state')
  const categories = [group, admin, state]
  const [filterBy, setFilterBy] = useState(categories[0])
  const [isStateSelectExpanded, setIsStateSelectExpanded] = useState(false)
  const [filters] = useState({
    [group]: [],
    [admin]: [],
    [state]: []
  })

  const textInputRef = useRef<HTMLInputElement>(null)

  const options = [
    { key: 'approved', value: t('state.approved') },
    { key: 'pending', value: t('state.pending') },
    { key: 'rejected', value: t('state.rejected') },
    { key: 'suspended', value: t('state.suspended') }
  ]

  const dataToolbarFilters = categories.map((o) => (
    <DataToolbarFilter
      key={o}
      chips={filters[o]}
      categoryName={o}
    >
      <span />
    </DataToolbarFilter>
  ))

  const CategorySelect = () => {
    const [isCategorySelectExpanded, setIsCategorySelectExpanded] = useState(false)

    const onSelectCategory = (_: any, value: string | SelectOptionObject) => {
      setFilterBy(value as string)
      setIsCategorySelectExpanded(false)

      textInputRef.current?.focus()
    }

    return (
      <Select
        toggleIcon={<FilterIcon />}
        variant={SelectVariant.single}
        aria-label={t('accounts_table.data_toolbar.search_widget.select_aria_label')}
        onSelect={onSelectCategory}
        selections={filterBy}
        isExpanded={isCategorySelectExpanded}
        onToggle={setIsCategorySelectExpanded}
        ariaLabelledBy="title-id"
        isDisabled={false}
      >
        {categories.map((c) => <SelectOption key={c} value={c} />)}
      </Select>
    )
  }

  const searchBar = (
    <InputGroup>
      <TextInput
        ref={textInputRef}
        type="search"
        aria-label={t('accounts_table.data_toolbar.search_widget.text_input_aria_label')}
        placeholder={t('accounts_table.data_toolbar.search_widget.placeholder', { option: filterBy.toLowerCase() })}
      />
      <Button
        variant={ButtonVariant.control}
        aria-label={t('accounts_table.data_toolbar.search_widget.button_aria_label')}
      >
        <SearchIcon />
      </Button>
    </InputGroup>
  )

  const stateSelect = (
    <Select
      variant={SelectVariant.checkbox}
      aria-label={t('accounts_table.data_toolbar.search_widget.select_state_aria_label')}
      onSelect={() => {}}
      selections={filters[state]}
      isExpanded={isStateSelectExpanded}
      onToggle={setIsStateSelectExpanded}
      placeholderText={t('accounts_table.data_toolbar.search_widget.placeholder', { option: filterBy.toLowerCase() })}
    >
      {options.map(({ key, value }) => <SelectOption key={key} value={value} />)}
    </Select>
  )

  return (
    <DataToolbarGroup variant="filter-group">
      <CategorySelect />
      {dataToolbarFilters}
      {filterBy === state ? stateSelect : searchBar}
    </DataToolbarGroup>
  )
}

export { SearchWidget }
