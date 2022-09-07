import * as React from 'react';

import {
  QuickStartCatalogPage,
  QuickStartContainer as PF4QuickStartContainer,
  useLocalStorage
} from '@patternfly/quickstarts/dist/quickstarts-full.es'
import { createReactWrapper } from 'utilities'
import quickStarts from 'QuickStarts/templates'
import replaceLinksExtension from 'QuickStarts/utils/replaceLinksExtension'

import './QuickStartContainer.scss'

type Props = {
  links: Array<[string, string, string]>,
  renderCatalog?: boolean
};

const CATALOG_CONTAINER_ID = 'quick-start-catalog-page-wrapper'

const QuickStartContainer = (
  {
    links,
    renderCatalog,
  }: Props,
): React.ReactElement => {
  const [activeQuickStartID, setActiveQuickStartID] = useLocalStorage('quickstartId', '')
  const [allQuickStartStates, setAllQuickStartStates] = useLocalStorage('quickstarts', {})

  const markdown = {
    renderExtension: (docContext, rootSelector) => <></>, // TODO: remove this when bug is fixed
    extensions: [replaceLinksExtension(links)]
  } as const

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
      markdown={markdown}
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
