import React, { useState, useRef, useMemo } from 'react'
import {
  SelectOption,
  Select,
  SelectVariant,
  InputGroup,
  TextInput,
  Button,
  ButtonVariant,
  SelectOptionObject,
  ToolbarFilter,
  ToolbarGroup,
  ToolbarChip,
  ToolbarChipGroup
} from '@patternfly/react-core'
import { FilterIcon, SearchIcon } from '@patternfly/react-icons'
import { useDataListFilters } from 'components'
import { useTranslation } from 'i18n/useTranslation'
import { Category, CategoryOption } from 'types'

import './searchWidget.scss'

interface ICategorySelect {
  categories: Category[]
  selections: string
  onCategorySelect: (c: string) => void
}

const CategorySelect: React.FunctionComponent<ICategorySelect> = ({
  categories,
  selections,
  onCategorySelect
}) => {
  const { t } = useTranslation('shared')
  const [isOpen, setIsOpen] = useState(false)
  const onSelect = (_: any, value: SelectOptionObject) => {
    onCategorySelect((value as { name: string }).name)
    setIsOpen(false)
  }
  return (
    <Select
      toggleIcon={<FilterIcon />}
      variant={SelectVariant.single}
      aria-label={t('data_list_filter.category_select_aria_label')}
      onSelect={onSelect}
      selections={selections}
      isOpen={isOpen}
      onToggle={setIsOpen}
      isDisabled={false}
    >
      { categories.map((category) => (
        <SelectOption
          key={category.name}
          value={{ name: category.name, toString: () => category.humanName } as SelectOptionObject}
        />
      ))}
    </Select>
  )
}

interface ICollectionSelect {
  onCollectionSelect: (checked: boolean, selection: string) => void
  options: CategoryOption[]
  selections: string[]
  categoryName: string
}

const OptionsSelect: React.FunctionComponent<ICollectionSelect> = ({
  onCollectionSelect,
  options,
  selections,
  categoryName
}) => {
  const { t } = useTranslation('shared')
  const [isOpen, setIsOpen] = useState(false)
  const onSelect = (ev: React.SyntheticEvent, selection: string | SelectOptionObject) => {
    const { checked } = ev.currentTarget as HTMLInputElement
    onCollectionSelect(checked, selection as string)
  }
  return (
    <Select
      aria-label={t('data_list_filter.state_select_aria_label')}
      variant={SelectVariant.checkbox}
      onSelect={onSelect}
      selections={selections}
      isOpen={isOpen}
      onToggle={setIsOpen}
      placeholderText={t('accountsIndex:accounts_filter_field', { filter_option: categoryName })}
    >
      { options.map(({ name, humanName }) => (
        <SelectOption key={name} value={humanName} />
      )) }
    </Select>
  )
}

interface ISearchBar {
  textInputRef: React.RefObject<HTMLInputElement>
  category: Category
  onSearchClick: (value: string) => void
}

const SearchBar = ({ textInputRef, category, onSearchClick }: ISearchBar) => {
  const { t } = useTranslation('shared')
  const onClick = () => {
    if (textInputRef.current?.value) {
      onSearchClick(textInputRef.current.value)
      // eslint-disable-next-line no-param-reassign
      textInputRef.current.value = ''
    }
  }
  return (
    <InputGroup>
      <TextInput
        ref={textInputRef}
        type="search"
        aria-label={t('accountsIndex:accounts_filter_field_aria_label')}
        placeholder={t('accountsIndex:accounts_filter_field', { filter_option: category.humanName })}
        onKeyUp={(ev) => ev.key === 'Enter' && onClick()}
      />
      <Button
        aria-label={t('accountsIndex:accounts_filter_button_aria_label')}
        variant={ButtonVariant.control}
        onClick={onClick}
      >
        <SearchIcon />
      </Button>
    </InputGroup>
  )
}

type SearchWidgetProps = {
  categories: Category[]
}

const SearchWidget: React.FunctionComponent<SearchWidgetProps> = ({ categories }) => {
  const { filters, setFilters } = useDataListFilters()
  const [selectedCategory, setSelectedCategory] = useState(categories[0])
  const textInputRef = useRef<HTMLInputElement>(null)

  const onCategorySelect = (name: string) => {
    setSelectedCategory(categories.find((category) => category.name === name) as Category)
    textInputRef.current?.focus()
  }

  const addFilter = (categoryName: string, term: string) => {
    if (!filters[categoryName] || filters[categoryName].indexOf(term) === -1) {
      const prevCatFilters = filters[categoryName] || []
      setFilters({ ...filters, [categoryName]: prevCatFilters.concat(term) })
    }
  }

  const removeFilter = (categoryName: string, term: string) => {
    setFilters(({ ...filters, [categoryName]: filters[categoryName]?.filter((s) => s !== term) }))
  }

  const onCollectionSelect = (categoryName: string) => (checked: boolean, option: string) => (
    (checked) ? addFilter(categoryName, option) : removeFilter(categoryName, option)
  )

  const onSearchClick = (value: string) => addFilter(selectedCategory.name, value)

  const deleteChip = (
    categoryHumanName: string | ToolbarChipGroup,
    chip: string | ToolbarChip
  ) => {
    // FIXME: PF ToolbarFilter deleteChip passes the categoryName instead of category (key)
    // Otherwise we could just use the removeFilter fn directly
    const category = categories.find((cat) => cat.humanName === categoryHumanName) as Category
    removeFilter(category.name, chip as string)
  }

  const appliedFilters = useMemo(() => categories.map((category) => (
    <ToolbarFilter
      key={category.name}
      chips={filters[category.name]}
      deleteChip={deleteChip}
      categoryName={category.humanName}
    >
      <span />
    </ToolbarFilter>
  )), [filters])

  const categorySelect = useMemo(() => (
    <CategorySelect
      onCategorySelect={onCategorySelect}
      selections={selectedCategory.humanName}
      categories={categories}
    />
  ), [selectedCategory])

  return (
    <ToolbarGroup variant="filter-group">
      { categorySelect }
      { appliedFilters }
      { selectedCategory.options
        ? (
          <OptionsSelect
            options={selectedCategory.options}
            selections={filters[selectedCategory.name] || []}
            categoryName={selectedCategory.humanName}
            onCollectionSelect={onCollectionSelect(selectedCategory.name)}
          />
        )
        : (
          <SearchBar
            textInputRef={textInputRef}
            category={selectedCategory}
            onSearchClick={onSearchClick}
          />
        ) }
    </ToolbarGroup>
  )
}

export { SearchWidget }
