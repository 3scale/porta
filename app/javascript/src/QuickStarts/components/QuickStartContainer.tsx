/* eslint-disable @typescript-eslint/no-unsafe-assignment */

import { QuickStartContainer as PF4QuickStartContainer, useLocalStorage } from '@patternfly/quickstarts'
import { PageSection } from '@patternfly/react-core'

import quickStarts from 'QuickStarts/templates'
import { replaceLinksExtension, imageAssetPathExtension } from 'QuickStarts/utils/markdownExtensions'
import { createReactWrapper } from 'utilities/createReactWrapper'

import { CustomCatalog } from './CustomCatalog'

interface Props {
  images: Record<string, string>;
  links: [string, string, string][];
  renderCatalog?: boolean;
}

const CATALOG_CONTAINER_ID = 'quick-start-catalog-page-wrapper'

const QuickStartContainer: React.FunctionComponent<Props> = ({
  images,
  links,
  renderCatalog = false
}) => {
  const [activeQuickStartID, setActiveQuickStartID] = useLocalStorage('quickstartId', '')
  const [allQuickStartStates, setAllQuickStartStates] = useLocalStorage('quickstarts', {})

  const markdown = {
    // eslint-disable-next-line react/no-multi-comp, react/jsx-no-useless-fragment -- TODO: remove this when bug is fixed
    renderExtension: () => <></>,
    extensions: [replaceLinksExtension(links), imageAssetPathExtension(images)]
  }

  return (
    <PF4QuickStartContainer
      useLegacyHeaderColors
      activeQuickStartID={activeQuickStartID}
      allQuickStartStates={allQuickStartStates}
      language="en"
      loading={false}
      markdown={markdown}
      quickStarts={quickStarts}
      setActiveQuickStartID={setActiveQuickStartID}
      setAllQuickStartStates={setAllQuickStartStates}
      showCardFooters={false}
    >
      {/* HACK: when container has no children, it messes with the page's height */}
      <div style={{ display: 'none' }}>test</div>

      {renderCatalog && (
        <div id={CATALOG_CONTAINER_ID}>
          <PageSection>
            <CustomCatalog />
          </PageSection>
        </div>
      )}
    </PF4QuickStartContainer>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const QuickStartContainerWrapper = (props: Props, containerId: string): void => { createReactWrapper(<QuickStartContainer {...props} />, containerId) }

export { QuickStartContainer, QuickStartContainerWrapper }
