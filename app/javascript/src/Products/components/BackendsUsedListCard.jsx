// @flow

import * as React from 'react'
import { useState, useRef } from 'react'

import { CompactListCard } from 'Common'
import { createReactWrapper, useSearchInputEffect } from 'utilities'

import type { CompactListItem } from 'Common'

type Props = {
  backends: Array<CompactListItem>
}

const BackendsUsedListCard = ({ backends }: Props): React.Node => {
  const [page, setPage] = useState(1)
  const [filteredBackends, setFilteredBackends] = useState(backends)
  const searchInputRef = useRef<HTMLInputElement | null>(null)

  const handleOnSearch = (term: string = '') => {
    setFilteredBackends(backends.filter(b => {
      const regex = new RegExp(term, 'i')
      return regex.test(b.name)
    }))
    setPage(1)
  }

  useSearchInputEffect(searchInputRef, handleOnSearch)

  return (
    <CompactListCard
      columns={['Name', 'Private Endpoint']}
      items={filteredBackends}
      searchInputRef={searchInputRef}
      onSearch={handleOnSearch}
      page={page}
      setPage={setPage}
      searchInputPlaceholder="Find a Backend"
      tableAriaLabel="Backends used by this product"
    />
  )
}

const BackendsUsedListCardWrapper = (props: Props, containerId: string): void => createReactWrapper(<BackendsUsedListCard {...props} />, containerId)

export { BackendsUsedListCard, BackendsUsedListCardWrapper }
