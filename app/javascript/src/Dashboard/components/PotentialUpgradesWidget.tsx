import pluralize from 'pluralize'

import { createReactWrapper } from 'utilities/createReactWrapper'

import type { FunctionComponent } from 'react'

export interface Violation {
  id: number;
  accountId: number;
  accountName: string;
  alertsCount: number;
  url: string;
}

export interface Links {
  adminServiceApplicationPlans: string;
  settingsAdminService: string;
}

interface Props {
  violations?: Violation[];
  incorrectSetUp?: boolean;
  links?: Links;
}

const PotentialUpgradesWidget: FunctionComponent<Props> = ({
  violations = [],
  incorrectSetUp = true,
  links = { adminServiceApplicationPlans: '', settingsAdminService: '' }
}) => (
  <article className="DashboardWidget" id="dashboard-widget-potential_upgrades">
    <h1 className="DashboardWidget-title">
      Potential Upgrades
    </h1>
    <span className="DashboardWidget-intro">
      Accounts that hit their Usage Limits in the last 30 days
    </span>

    {(incorrectSetUp)
      ? (
        <div>
          <p>
          In order to show Potential Upgrades, add 1 or more usage limits to your <a href={links.adminServiceApplicationPlans}>Application Plans</a>.
          </p>
          <p>
          Furthermore, <a href={links.settingsAdminService}>Web Alerts for Admins of this Account of 100% (and up)</a> should be enabled for service(s) with usage limits.
          </p>
        </div>
      )
      : violations.length > 0
        ? (
          <ol className="DashboardWidgetList">
            {violations.map(
              violation => (
                // eslint-disable-next-line react/jsx-key
                <li className="DashboardWidgetList-item">
                  <a className="DashboardWidgetList-link" href={violation.url}>
                    {violation.accountName} has {violation.alertsCount} { pluralize('Usage Limit alert', violation.alertsCount) }
                  </a>
                </li>
              )
            )}
          </ol>
        )
        : <p>No Potential Upgrades. Yet…</p>}
  </article>
)

// eslint-disable-next-line react/jsx-props-no-spreading
const PotentialUpgradesWidgetWrapper = (props: Props, containerId: string): void => { createReactWrapper(<PotentialUpgradesWidget {...props} />, containerId) }

export { PotentialUpgradesWidget, PotentialUpgradesWidgetWrapper, Props }
