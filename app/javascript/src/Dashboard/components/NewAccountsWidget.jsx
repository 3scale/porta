// @flow

import React, { useState, useEffect } from 'react'

import { createReactWrapper } from 'utilities'
import { render as renderChartWidget } from 'Dashboard/chart'
import { Spinner } from 'Common'
import 'Dashboard/styles/dashboard.scss'

type ChartValues = {
  value: number,
  formatted_value: string
}

type Props = {
  chartData: {
    values: Map<Date, ChartValues>,
    complete: Map<Date, ChartValues>,
    incomplete: Map<Date, ChartValues>,
    previous: Map<Date, ChartValues>
  },
  newAccountsTotal: number,
  hasHistory: boolean,
  links: {
    previousRangeAdminBuyersAccount: {
      url: string,
      value: string
    },
    currentRangeAdminBuyersAccount: {
      url: string,
      value: string
    }
  },
  percentualChange: number
}

const NewAccountsWidget = ({ chartData, newAccountsTotal, hasHistory, links, percentualChange }: Props): React.Node => {
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    renderChartWidget(document.getElementById('dashboard-widget-new_accounts'), chartData)
    setIsLoading(false)
  }, [])

  return (
    <article className="DashboardWidget" id="dashboard-widget-new_accounts">
      {isLoading && <Spinner size="md" isSVG className="pf-u-ml-md DashboardWidget-spinner" />}
      <div className="Dashboard-chart c3" data-chart/>
      <header className="DashboardWidget-badge">
        <h1 className="DashboardWidget-title">
          <a className="DashboardWidget-link" href="">
            <strong data-title-count="true">{newAccountsTotal}</strong> Signups
          </a>
        </h1>
        <div className="DashboardWidget-percentageInfo" data-toggle-visibility="true">
          {
            hasHistory
              ? <a href={links.currentRangeAdminBuyersAccount.url} className="DashboardWidget-link DashboardWidget-link--today">
                  {links.currentRangeAdminBuyersAccount.value}
                </a>
              : <a href={links.previousRangeAdminBuyersAccount.url} className={`DashboardWidget-link ${percentualChange > 0 ? 'u-plus' : 'u-minus' }`}>
                  {links.previousRangeAdminBuyersAccount.value}
                </a>
          }
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

const NewAccountsWidgetWrapper = (props: Props, containerId: string): void => createReactWrapper(<NewAccountsWidget {...props} />, containerId)

export { NewAccountsWidgetWrapper }
