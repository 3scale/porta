// @flow

import React from 'react'

import { createReactWrapper } from 'utilities'
import pluralize from 'pluralize'

import 'Dashboard/styles/dashboard.scss'

type Props = {
  violations: Array<{
    id: number,
    account_id: number,
    account_name: string,
    alerts_count: number,
    url: string
  }>,
  incorrectSetUp: boolean,
  links: {
    adminServiceApplicationPlans: string,
    settingsAdminService: string
  }
}

const PotentialUpgradesWidget = ({ violations, incorrectSetUp, links }: Props) => {
  return (
    <article className='DashboardWidget' id='dashboard-widget-potential_upgrades'>
      <h1 className='DashboardWidget-title'>
        Potential Upgrades
      </h1>
      <span className='DashboardWidget-intro'>
        Accounts that hit their Usage Limits in the last 30 days
      </span>

      {
        violations.some((violation) => violation)
          ? <ol className='DashboardWidgetList'>
            {
              violations.map(violation =>
                <li className='DashboardWidgetList-item' key={violation.account_id}>
                  <a href={violation.url} className='DashboardWidgetList-link'>
                    {violation.account_name} has {violation.alerts_count} { pluralize('Usage Limit alert', violation.alerts_count) }
                  </a>
                </li>
            )}
          </ol>
          : (incorrectSetUp)
            ? <>
                <p>
                  In order to show Potential Upgrades, add 1 or more usage limits to your <a href={links.adminServiceApplicationPlans}>Application Plans</a>.
                </p>
                <p>
                  Furthermore, <a href={links.settingsAdminService}>Web Alerts for Admins of this Account of 100% (and up)</a> should be enabled for service(s) with usage limits.
                </p>
              </>
          : <p>No Potential Upgrades. Yet…</p>
      }
    </article>
  )
}

const PotentialUpgradesWidgetWrapper = (props: Props, containerId: string): void => createReactWrapper(<PotentialUpgradesWidget {...props} />, containerId)

export { PotentialUpgradesWidgetWrapper }
