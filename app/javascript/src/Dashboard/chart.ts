/* eslint-disable @typescript-eslint/no-unsafe-call */
/* eslint-disable @typescript-eslint/no-unsafe-argument */
/* eslint-disable @typescript-eslint/no-unsafe-member-access */
/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable @typescript-eslint/explicit-module-boundary-types */
// FIXME: we need to properly type this
import $ from 'jquery'
import moment from 'moment'
import numeral from 'numeral'
import c3 from 'c3'

import type { MomentInput, MomentInputObject } from 'moment'

export function render (widget: string, data: unknown): void {
  const options = chartOptions(widget, data)
  $('[data-chart]', widget).each(function (_, chart) {
    c3.generate(($ as any).extend(true, {}, options, { bindto: chart }))
  })
}

function chartOptions (widget: string, data: any) {
  const $widget = $(widget)
  const values = timeline(data.values)
  const seriesData = [['date', ...values[0]], ['hits', ...values[1]]]
  const countLabel = $widget.find('[data-title-count]')
  const lastSerieIndex = seriesData[1].length - 1
  const introLabel = $widget.find('[data-title-intro]')
  const elementsToHide = $widget.find('[data-toggle-visibility]')
  const countLabelLink = countLabel.closest('a')
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

        elementsToHide.stop().fadeOut(100)
        countLabelLink.toggleClass('DashboardWidget-link--infoOnly')
      },
      onmouseout: function () {
        countLabel.text(defaultCount)
        introLabel.text(defaultIntro)

        elementsToHide.stop().fadeIn(100)
        countLabelLink.toggleClass('DashboardWidget-link--infoOnly')
      }
    }
  }
}

/**
 * Converts object where keys are string dates to array with real date objects
 */
function timeline (data: MomentInputObject) {
  const dates = Object.keys(data)
  const x: string[] = []
  const y: string[] = []

  dates.forEach(date => {
    x.push(moment.utc(date).toISOString())
    y.push((data as any)[date].value)
  })
  return [x, y]
}

function getIntroLabel (timestamp: MomentInput) {
  if (moment().isSame(timestamp, 'day')) {
    return 'today'
  } else {
    return moment(timestamp).format('D MMMM YYYY')
  }
}
