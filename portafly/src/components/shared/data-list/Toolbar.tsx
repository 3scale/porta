import React from 'react'
import { Toolbar } from '@patternfly/react-core'
import { useDataListFilters } from 'components'

interface Props {
}

const DataListToolbar: React.FunctionComponent<Props> = ({ children }) => {
  const { setFilters } = useDataListFilters()
  return (
    <Toolbar id="toolbar" clearAllFilters={() => setFilters({})}>
      {children}
    </Toolbar>
  )
}

export { DataListToolbar as Toolbar }
