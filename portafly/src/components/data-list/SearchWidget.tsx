import React, { useState, useRef, useMemo } from 'react'
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
import {
  DataToolbarFilter,
  DataToolbarGroup,
  DataToolbarChip,
  DataToolbarChipGroup
} from '@patternfly/react-core/dist/js/experimental'
import { useDataListFilters } from 'components/data-list/'

import './searchWidget.scss'

type CategoryOptions = Record<string, string>
type Category = {
  name: string
  humanName: string
  options?: CategoryOptions
}

interface ICategorySelect {
  categories: Category[]
  selections: string
  onCategorySelect: (c: string) => void
}

// FIXME: PF Select is not quite open to change...
interface SelectOptionProps extends SelectOptionObject {
  key: string
}

const CategorySelect = ({ categories, selections, onCategorySelect }: ICategorySelect) => {
  const [isExpanded, setIsExpanded] = useState(false)
  const onSelect = (_: any, value: SelectOptionProps) => {
    onCategorySelect(value.key)
    setIsExpanded(false)
  }
  return (
    <Select
      toggleIcon={<FilterIcon />}
      variant={SelectVariant.single}
      aria-label="category-select"
      // FIXME: PF Select is not quite open to change... thus, ts-ignore.
      // @ts-ignore
      onSelect={onSelect}
      selections={selections}
      isExpanded={isExpanded}
      onToggle={setIsExpanded}
      isDisabled={false}
    >
      { categories.map((category) => (
        <SelectOption
          key={category.name}
          // FIXME: PF Select does not contemplate the need of localized values or key: value pairs
          // @ts-ignore
          value={{ key: category.name, toString: () => category.humanName }}
        />
      ))}
    </Select>
  )
}

interface ICollectionSelect {
  onCollectionSelect: (checked: boolean, selection: string) => void
  collection: CategoryOptions
  selections: string[]
  categoryName: string
}

const CollectionSelect = ({
  onCollectionSelect, collection, selections, categoryName
}: ICollectionSelect) => {
  const [isExpanded, setIsExpanded] = useState(false)
  const onSelect = (ev: React.SyntheticEvent, selection: string | SelectOptionObject) => {
    const { checked } = ev.currentTarget as HTMLInputElement
    onCollectionSelect(checked, selection as string)
  }
  return (
    <Select
      variant={SelectVariant.checkbox}
      onSelect={onSelect}
      selections={selections}
      isExpanded={isExpanded}
      onToggle={setIsExpanded}
      placeholderText={`Filter by ${categoryName}`}
    >
      { Object.keys(collection).map((key) => (
        <SelectOption key={key} value={collection[key]} />
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
        aria-label="Aria label of the text input for filtering"
        placeholder={`Filter by ${category.humanName}`}
        onKeyUp={(ev) => ev.key === 'Enter' && onClick()}
      />
      <Button
        variant={ButtonVariant.control}
        aria-label="Aria label for button"
        onClick={onClick}
      >
        <SearchIcon />
      </Button>
    </InputGroup>
  )
}

interface ISearchWidget {
  categories: Category[]
}

const SearchWidget: React.FunctionComponent<ISearchWidget> = ({ categories }) => {
  const [selectedCategory, setSelectedCategory] = useState(categories[0])
  const textInputRef = useRef<HTMLInputElement>(null)
  const { filters, setFilters } = useDataListFilters()


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
    categoryHumanName: string | DataToolbarChipGroup,
    chip: string | DataToolbarChip
  ) => {
    // FIXME: PF DataToolbarFilter deleteChip passes the categoryName instead of category (key)
    // Otherwise we could just use the removeFilter fn directly
    const category = categories.find((cat) => cat.humanName === categoryHumanName) as Category
    removeFilter(category.name, chip as string)
  }

  const appliedFilters = useMemo(() => categories.map((category) => (
    <DataToolbarFilter
      key={category.name}
      chips={filters[category.name]}
      deleteChip={deleteChip}
      categoryName={category.humanName}
    >
      <span />
    </DataToolbarFilter>
  )), [filters])

  const categorySelect = useMemo(() => (
    <CategorySelect
      onCategorySelect={onCategorySelect}
      selections={selectedCategory.humanName}
      categories={categories}
    />
  ), [selectedCategory])

  return (
    <DataToolbarGroup variant="filter-group">
      { categorySelect }
      { appliedFilters }
      { selectedCategory.options
        ? (
          <CollectionSelect
            collection={selectedCategory.options as CategoryOptions}
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
    </DataToolbarGroup>
  )
}

export { SearchWidget }
