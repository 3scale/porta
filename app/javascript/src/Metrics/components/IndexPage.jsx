// @flow

import * as React from 'react'
import { useState } from 'react'

import {
  Card,
  CardBody,
  PageSection,
  PageSectionVariants,
  Tabs,
  Tab
} from '@patternfly/react-core'
// $FlowFixMe[missing-export] name-mapper error with MetricsTable
import { MethodsTable, MetricsTable } from 'Metrics'

import './IndexPage.scss'

type Props = {
  infoCard: React.Node
}

type TabKey = 'methods' | 'metrics'

const IndexPage = ({ infoCard }: Props): React.Node => {
  const [activeTabKey, setActiveTabKey] = useState<TabKey>('methods')

  const handleTabClick = (_event, tabIndex: TabKey) => {
    setActiveTabKey(tabIndex)
  }

  return (
    <>
      <PageSection variant={PageSectionVariants.light}>
        <h1>Methods & Metrics</h1>
      </PageSection>

      <Tabs activeKey={activeTabKey} onSelect={handleTabClick}>
        <Tab eventKey="methods" title="Methods"></Tab>
        <Tab eventKey="metrics" title="Metrics"></Tab>
      </Tabs>

      <PageSection>
        <Card>
          <CardBody>
            {infoCard}
          </CardBody>
        </Card>

        <Card>
          <CardBody>
            {/* HACK: This should work by default, but we're using an old PF version. Update when upgraded to v4. */}
            { activeTabKey === 'methods' ? <MethodsTable /> : <MetricsTable />}
            {/* HACK_END */}
          </CardBody>
        </Card>
      </PageSection>

    </>
  )
}

export { IndexPage }
