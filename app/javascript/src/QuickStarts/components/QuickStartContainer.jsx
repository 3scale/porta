// @flow

import * as React from 'react'

import {
  QuickStartCatalogPage,
  QuickStartContainer as PF4QuickStartContainer,
  useLocalStorage
} from '@patternfly/quickstarts/dist/quickstarts-full.es'
import { createReactWrapper } from 'utilities'
import quickStarts from 'QuickStarts/templates'

import './QuickStartContainer.scss'

type Props = {
  renderCatalog?: boolean
}

const CATALOG_CONTAINER_ID = 'quick-start-catalog-page-wrapper'

const QuickStartContainer = ({ renderCatalog }: Props): React.Node => {
  const [activeQuickStartID, setActiveQuickStartID] = useLocalStorage('quickstartId', '')
  const [allQuickStartStates, setAllQuickStartStates] = useLocalStorage('quickstarts', {})

  return (
    <PF4QuickStartContainer
      quickStarts={quickStarts}
      activeQuickStartID={activeQuickStartID}
      setActiveQuickStartID={setActiveQuickStartID}
      allQuickStartStates={allQuickStartStates}
      setAllQuickStartStates={setAllQuickStartStates}
      showCardFooters={false}
      loading={false}
      language="en"
      useLegacyHeaderColors
    >
      {/* HACK: when container has no children, it messes with the page's height */}
      <div style={{ display: 'none' }}>test</div>

      {renderCatalog && (
        <div id={CATALOG_CONTAINER_ID}>
          <QuickStartCatalogPage
            showFilter
            title="Quick starts"
            hint="Learn how to create, import, and run applications with step-by-step instructions and tasks."
          />
        </div>
      )}
    </PF4QuickStartContainer>
  )
}

const QuickStartContainerWrapper = (props: Props, containerId: string): void => createReactWrapper(<QuickStartContainer {...props} />, containerId)

export { QuickStartContainer, QuickStartContainerWrapper }
