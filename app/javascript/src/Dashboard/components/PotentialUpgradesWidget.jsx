// @flow

import * as React from 'react'

import { createReactWrapper } from 'utilities'
import pluralize from 'pluralize'

export type Violation = {
  id: number,
  account_id: number,
  account_name: string,
  alerts_count: number,
  url: string
}

export type Links = {
  adminServiceApplicationPlans: string,
  settingsAdminService: string
}

export type Props = {
  violations: Array<Violation>,
  incorrectSetUp: boolean,
  links: Links
}

const IncorrectSetUpMessages = ({ links }: {links: Links}) => (
  <div>
    <p>
      In order to show Potential Upgrades, add 1 or more usage limits to your <a href={links.adminServiceApplicationPlans}>Application Plans</a>.
    </p>
    <p>
      Furthermore, <a href={links.settingsAdminService}>Web Alerts for Admins of this Account of 100% (and up)</a> should be enabled for service(s) with usage limits.
    </p>
  </div>
)

const ViolationsList = ({ violations }: {violations: Array<Violation>}): React.Node => {
  const violationsList = violations.map(
    violation => <PotentialUpgradeWidgetItem violation={violation} key={violation.account_id}/>
  )

  return (
    <ol className='DashboardWidgetList'>
      { violationsList }
    </ol>
  )
}

const PotentialUpgradeWidgetItem = ({ violation }: {violation: Violation}) => (
  <li className='DashboardWidgetList-item'>
    <a href={violation.url} className='DashboardWidgetList-link'>
      {violation.account_name} has {violation.alerts_count} { pluralize('Usage Limit alert', violation.alerts_count) }
    </a>
  </li>
)

const PotentialUpgradesWidget = ({ violations, incorrectSetUp, links }: Props): React.Node => (
  <article className='DashboardWidget' id='dashboard-widget-potential_upgrades'>
    <h1 className='DashboardWidget-title'>
      Potential Upgrades
    </h1>
    <span className='DashboardWidget-intro'>
      Accounts that hit their Usage Limits in the last 30 days
    </span>

    {
      (incorrectSetUp)
        ? <IncorrectSetUpMessages links={links}/>
        : violations.length > 0
          ? <ViolationsList violations={violations}/>
        : <p>No Potential Upgrades. Yet…</p>
    }
  </article>
)

const PotentialUpgradesWidgetWrapper = (props: Props, containerId: string): void => createReactWrapper(<PotentialUpgradesWidget {...props} />, containerId)

export { PotentialUpgradesWidget, PotentialUpgradesWidgetWrapper }
