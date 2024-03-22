/* eslint-disable react/jsx-props-no-spreading */
import {
  ToolbarToggleGroup,
  ToolbarGroup,
  ToolbarItem,
  Popper,
  ToolbarFilter,
  Menu,
  MenuContent,
  MenuItem,
  MenuList,
  MenuToggle
} from '@patternfly/react-core'
import { useRef, useState } from 'react'
import FilterIcon from '@patternfly/react-icons/dist/js/icons/filter-icon'

import { ToolbarSearch } from 'Common/components/ToolbarSearch'
import { ToolbarSelect } from 'Common/components/ToolbarSelect'
import { ToolbarGroupedSelect } from 'Common/components/ToolbarGroupedSelect'

import type { FunctionComponent } from 'react'

interface Item {
  id: string;
  title: string;
}

export interface AttributeSearchFilter {
  chip?: string;
  collection?: Item[];
  groupedCollection?: {
    groupName: string;
    groupCollection: Item[];
  }[];
  name: string;
  placeholder: string;
  title: string;
}

interface Props {
  filters: AttributeSearchFilter[];
}

const ToolbarAttributeSearch: FunctionComponent<Props> = ({ filters }) => {
  const [activeAttributeMenu, setActiveAttributeMenu] = useState<AttributeSearchFilter>(filters[0])
  const [isAttributeMenuOpen, setIsAttributeMenuOpen] = useState(false)
  const attributeContainerRef = useRef<HTMLDivElement>(null)

  const onAttributeToggleClick = () => { setIsAttributeMenuOpen(!isAttributeMenuOpen) }

  const onChipDelete = ({ name }: AttributeSearchFilter) => {
    const search = new URLSearchParams(window.location.search)
    search.delete(name)
    window.location.search = search.toString()
  }

  return (
    <ToolbarToggleGroup breakpoint="md" toggleIcon={<FilterIcon />}>
      <ToolbarGroup data-ouia-component-id="attribute-search" variant="filter-group">
        <ToolbarItem>
          <div ref={attributeContainerRef}>
            <Popper
              appendTo={attributeContainerRef.current ?? undefined}
              isVisible={isAttributeMenuOpen}
              popper={(
                <Menu
                  onSelect={(_ev, itemId) => {
                    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
                    setActiveAttributeMenu(filters.find(s => s.name === itemId)!)
                    setIsAttributeMenuOpen(!isAttributeMenuOpen)
                  }}
                >
                  <MenuContent>
                    <MenuList>
                      {filters.map(({ name, title }) => (
                        <MenuItem key={name} itemId={name}>{title}</MenuItem>
                      ))}
                    </MenuList>
                  </MenuContent>
                </Menu>
              )}
              trigger={(
                <MenuToggle
                  icon={<FilterIcon />}
                  isExpanded={isAttributeMenuOpen}
                  onClick={onAttributeToggleClick}
                >
                  {activeAttributeMenu.title}
                </MenuToggle>
              )}
            />
          </div>
        </ToolbarItem>
        {filters.map(({ collection, groupedCollection, chip, ...attr }) => (
          <ToolbarFilter
            key={attr.name}
            categoryName={attr.title}
            chips={chip ? [chip] : undefined}
            deleteChip={() => { onChipDelete(attr) }}
            showToolbarItem={activeAttributeMenu.name === attr.name}
          >
            {collection !== undefined ? (
              <ToolbarSelect collection={collection} {...attr} />
            ) : groupedCollection !== undefined ? (
              <ToolbarGroupedSelect collection={groupedCollection} selected={chip} {...attr} />
            ) : (
              <ToolbarSearch {...attr} />
            )}
          </ToolbarFilter>
        ))}
      </ToolbarGroup>
    </ToolbarToggleGroup>
  )
}

export { ToolbarAttributeSearch }
