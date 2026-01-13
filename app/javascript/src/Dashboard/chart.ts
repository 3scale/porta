/* eslint-disable @typescript-eslint/no-unsafe-call */
/* eslint-disable @typescript-eslint/no-unsafe-argument */
/* eslint-disable @typescript-eslint/no-unsafe-member-access */
/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable @typescript-eslint/explicit-module-boundary-types */
// FIXME: we need to properly type this
import $ from 'jquery'
import moment, { utc } from 'moment'
import numeral from 'numeral'
import { generate } from 'c3'

import type { ChartData } from 'Types/threescale'
import type { MomentInput } from 'moment'

export function render (widget: HTMLElement, data: ChartData): void {
  const options = chartOptions(widget, data)
  $('.new-accounts-chart', widget).each(function (_, chart) {
    generate(($ as any).extend(true, {}, options, { bindto: chart }))
  })
}

function chartOptions (widget: HTMLElement, data: ChartData) {
  const $widget = $(widget)
  const [x, y] = parseData(data)
  const seriesData = [['date', ...x], ['hits', ...y]]
  const countLabel = $widget.find('.new-accounts-title-count')
  const lastSerieIndex = seriesData[1].length - 1
  const introLabel = $widget.find('[data-title-intro]')
  const defaultCount = countLabel.text()
  const defaultIntro = introLabel.text()

  return {
    axis: {
      x: {
        type: 'timeseries',
        show: false
      },
      y: {
        show: false
      }
    },
    legend: {
      show: false
    },
    tooltip: {
      show: false
    },
    data: {
      x: 'date',
      xFormat: '%Y-%m-%dT%H:%M:%S.%LZ',
      type: 'bar',
      columns: seriesData,
      color: function (color: string, d: { index: number }) {
        return (d.index && d.index === lastSerieIndex - 1) ? 'transparent' : '#DFDFDF'
      },
      onmouseover: function (d: any) {
        const value = numeral(d.value).format('0.[0]a').toUpperCase()
        const timestamp = Date.parse(d.x)
        countLabel.text(value)
        introLabel.text(getIntroLabel(timestamp))

        // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
        document.querySelector<HTMLElement>('[data-toggle-visibility]')!.style.setProperty('visibility', 'hidden')
      },
      onmouseout: function () {
        countLabel.text(defaultCount)
        introLabel.text(defaultIntro)

        // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
        document.querySelector<HTMLElement>('[data-toggle-visibility]')!.style.removeProperty('visibility')
      }
    }
  }
}

function parseData (data: ChartData) {
  const x = data.flatMap(pair => utc(pair[0]).toISOString())
  const y = data.flatMap(pair => pair[1])

  return [x, y]
}

function getIntroLabel (timestamp: MomentInput) {
  if (moment().isSame(timestamp, 'day')) {
    return 'today'
  } else {
    return moment(timestamp).format('D MMMM YYYY')
  }
}
