import { useEffect, useState } from 'react'

import { createReactWrapper } from 'utilities/createReactWrapper'
import { render as renderChartWidget } from 'Dashboard/chart'
import { Spinner } from 'Common/components/Spinner'

import type { FunctionComponent } from 'react'

interface ChartValues {
  value: number;
  formattedValue: string;
}

type ChartValuesByDate = Record<string, ChartValues>

interface ChartData {
  values: ChartValuesByDate;
  complete?: ChartValuesByDate;
  incomplete?: ChartValuesByDate;
  previous?: ChartValuesByDate;
}

interface PreviousRangeAdminBuyersAccount {
  url: string;
  value: string;
}

interface CurrentRangeAdminBuyersAccount {
  url: string;
}

interface LastDayInRangeAdminBuyersAccount {
  url: string;
  value: string;
}

interface Links {
  previousRangeAdminBuyersAccount: PreviousRangeAdminBuyersAccount;
  currentRangeAdminBuyersAccount: CurrentRangeAdminBuyersAccount;
  lastDayInRangeAdminBuyersAccount: LastDayInRangeAdminBuyersAccount;
}

interface Props {
  chartData?: ChartData;
  newAccountsTotal?: number;
  hasHistory?: boolean;
  links?: Links;
  percentualChange?: number;
}

const NewAccountsWidget: FunctionComponent<Props> = ({
  chartData = {},
  newAccountsTotal = 0,
  hasHistory = false,
  links = {
    previousRangeAdminBuyersAccount: {
      url: '',
      value: 0
    },
    currentRangeAdminBuyersAccount: {
      url: ''
    },
    lastDayInRangeAdminBuyersAccount: {
      url: '',
      value: 0
    }
  },
  percentualChange = 0
}) => {
  const [isLoading, setIsLoading] = useState(true)
  // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
  const chartWidget = document.querySelector<HTMLElement>('#dashboard-widget-new_accounts')!

  useEffect(() => {
    renderChartWidget(chartWidget, chartData)
    setIsLoading(false)
  }, [])

  return (
    <article className="DashboardWidget" id="dashboard-widget-new_accounts">
      {isLoading && <Spinner className="pf-u-ml-md DashboardWidget-spinner" size="md" />}
      <div data-chart className="Dashboard-chart c3" />
      <header className="DashboardWidget-badge">
        <h1 className="DashboardWidget-title">
          <a className="DashboardWidget-link" href={links.currentRangeAdminBuyersAccount.url}>
            <strong data-title-count="true">{newAccountsTotal}</strong> Signups
          </a>
        </h1>
        <div className="DashboardWidget-percentageInfo" data-toggle-visibility="true">
          {hasHistory
            ? (
              <a className={`DashboardWidget-link ${percentualChange > 0 ? 'u-plus' : 'u-minus' }`} href={links.previousRangeAdminBuyersAccount.url}>
                {links.previousRangeAdminBuyersAccount.value}
              </a>
            )
            : (
              <a className="DashboardWidget-link DashboardWidget-link--today" href={links.lastDayInRangeAdminBuyersAccount.url}>
                {links.lastDayInRangeAdminBuyersAccount.value}
              </a>
            )}
          <span className="DashboardWidget-intro DashboardWidget-intro--primary" data-title-intro="true">
            last 30 days
          </span>
          <span className="DashboardWidget-intro DashboardWidget-intro--secondary" data-toggle-visibility="true">
            {hasHistory ? 'vs. previous 30 days' : 'today'}
          </span>
        </div>
      </header>
    </article>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const NewAccountsWidgetWrapper = (props: Props, containerId: string): void => { createReactWrapper(<NewAccountsWidget {...props} />, containerId) }

export { NewAccountsWidget, NewAccountsWidgetWrapper, Props }
