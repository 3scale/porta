import { useEffect, useRef, useState } from 'react'
import { generate } from 'c3'
import moment from 'moment'
import numeral from 'numeral'

import { fetchData } from 'utilities/fetchData'
import { createReactWrapper } from 'utilities/createReactWrapper'

import type { IRecord } from 'Types'
import type { FunctionComponent } from 'react'

interface Props {
  endPoint: string;
  metricName: string;
  title: string;
  unitPluralized: string;
}

interface Data {
  application: IRecord & {
    account: IRecord & {
      link: string;
    };
    description: string;
    link: string;
    plan: IRecord;
    service: { id: number };
    state: string;
  };
  period: {
    name: string | null;
    since: string;
    until: string;
    timezone: string;
    granularity: string;
  };
  metric: IRecord & {
    // eslint-disable-next-line @typescript-eslint/naming-convention
    system_name: string;
    unit: string;
  };
  total: number;
  values: number[];
}

const InlineChart: FunctionComponent<Props> = ({
  endPoint,
  metricName,
  title,
  unitPluralized
}) => {
  const c3ChartContainer = useRef<HTMLDivElement>(null)
  const [loading, setLoading] = useState(true)
  const [total, setTotal] = useState(0)
  const [unit, setUnit] = useState('')

  function generateC3Chart (values: number[]) {
    const nodeElem = c3ChartContainer.current
    generate({
      bindto: nodeElem,
      axis: {
        x: { show: false },
        y: { show: false }
      },
      legend: { show: false },
      point: { show: false },
      data: {
        columns: [
          [metricName, ...values]
        ]
      },
      tooltip: {
        contents: (d) => `<span><i class='tooltip-dot'></i> ${d[0].value}</span>`
      },
      onresize: () => {
        if (nodeElem !== null) {
          nodeElem.style.maxHeight = 'none'
        }
      }
    })
  }

  function pluralizeUnit (data: Data): string {
    if (!data.metric.unit.endsWith('s') && data.total !== 1) {
      return unitPluralized
    }
    return data.metric.unit
  }

  function updateState (data: Data) {
    generateC3Chart(data.values)
    setLoading(false)
    setTotal(data.total)
    setUnit(pluralizeUnit(data))
  }

  function getURL (): URL {
    const today = moment(new Date())
    const until = today.format('YYYY-MM-DD')
    const since = today.subtract(30, 'day').format('YYYY-MM-DD')
    const granularity = 'day'
    const url = new URL(endPoint, window.location.origin)
    url.searchParams.append('metric_name', metricName)
    url.searchParams.append('since', since)
    url.searchParams.append('until', until)
    url.searchParams.append('granularity', granularity)
    return url
  }

  useEffect(() => {
    const url = getURL().toString()
    void fetchData<Data>(url).then(updateState)
  }, [])

  return (
    <>
      {loading && (
        <div className="loading">
          <i className="fa fa-spinner fa-spin" />
        </div>
      )}
      <div className="metric-name" title={title}>{title}</div>
      <div className="total">
        {`${numeral(total).format('0,0')} ${unit.substring(0, 10)}`}
      </div>
      <div className="inline-chart-graph" ref={c3ChartContainer} />
    </>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const InlineChartWrapper = (props: Props, containerId: string): void => { createReactWrapper(<InlineChart {...props} />, containerId) }

export type { Props }
export { InlineChart, InlineChartWrapper }
