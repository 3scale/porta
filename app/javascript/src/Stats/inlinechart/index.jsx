// @flow

import React, {Component } from 'react'
import type { Node } from 'react'
import c3 from 'c3'
import 'whatwg-fetch'
import 'core-js/es6/promise'
import 'url-polyfill'
import moment from 'moment'
import numeral from 'numeral'

type Props = {
    endPoint: string,
    metricName: string,
    title: string,
    unitPluralized: string
}

type State = {
    loading: boolean,
    title: string,
    total: string,
    values: Array<number>,
    unit: string,
    unitPluralized: string
}

type RefObject = { current: null | HTMLDivElement }

type DataMetric = {
    unit: string
}

type Data = {
    metric: DataMetric,
    total: number,
    values: Array<number>
}

type ResponseError = {
  status: string,
  statusText: string
}

class InlineChart extends Component<Props, State> {
  c3ChartContainer: RefObject

  constructor (props: Props) {
    super(props)
    this.c3ChartContainer = React.createRef()
    this.state = {
      loading: true,
      title: this.props.title,
      total: '',
      values: [],
      unit: '',
      unitPluralized: this.props.unitPluralized
    }
  }

  generateC3Chart () {
    const nodeElem = this.c3ChartContainer.current
    const optionsObj = {
      bindto: nodeElem,
      axis: {
        x: { show: false },
        y: { show: false }
      },
      legend: { show: false },
      point: { show: false },
      data: {
        columns: [
          [...this.state.values]
        ]
      },
      tooltip: {
        contents: function (d) {
          return `<span><i class='tooltip-dot'></i> ${d[0].value}</span>`
        }
      },
      onresize: function () {
        nodeElem.style.maxHeight = 'none'
      }
    }
    c3.generate(optionsObj)
  }

  getTotalAsString (total: number, unit: string): string {
    return `${numeral(total).format('0,0')} ${unit.substring(0, 10)}`
  }

  pluralizeUnit (unit: string, total: number): string {
    if (unit.slice(-1) !== 's' && total !== 1) {
      unit = this.state.unitPluralized
    }
    return unit
  }

  updateState (data: Data) {
    let unit = this.pluralizeUnit(data.metric.unit, data.total)
    const total = this.getTotalAsString(data.total, unit)

    this.setState({
      loading: false,
      total,
      unit,
      values: data.values
    }, () => this.generateC3Chart())
  }

  getURL (): URL {
    const { endPoint, metricName } = this.props
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

  throwError (response: ResponseError) {
    throw new Error(`${response.status} (${response.statusText})`)
  }

  async componentDidMount () {
    const response = await window.fetch(this.getURL())
    response.ok ? this.updateState(await response.json()) : this.throwError({status: response.status, statusText: response.statusText})
  }

  render (): Node {
    const { loading, title, total } = this.state
    return (
      <div>
        <div className={ `loading ${loading ? '' : 'hide'}` }>
          <i className="fa fa-spinner fa-spin"></i>
        </div>
        <div title={title} className="metric-name">{title}</div>
        <div className="total">{total}</div>
        <div className="inline-chart-graph" ref={this.c3ChartContainer}></div>
      </div>
    )
  }
}

export default InlineChart
