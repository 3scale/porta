import $ from 'jquery'
import moment from 'moment'
import numeral from 'numeral'
import c3 from 'c3'

export function render (widget, data) {
  let options = chartOptions(widget, data)
  $('[data-chart]', widget).each(function (_, chart) {
    return c3.generate($.extend(true, {}, options, { bindto: chart }))
  })
}

function chartOptions (widget, data) {
  let $widget = $(widget)
  let values = timeline(data.values)
  let seriesData = [['date', ...values[0]], ['hits', ...values[1]]]
  let countLabel = $widget.find('[data-title-count]')
  let lastSerieIndex = seriesData[1].length - 1
  let introLabel = $widget.find('[data-title-intro]')
  let elementsToHide = $widget.find('[data-toggle-visibility]')
  let countLabelLink = countLabel.closest('a')
  let defaultCount = countLabel.text()
  let defaultIntro = introLabel.text()

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
      color: function (color, d) {
        return (d.index && d.index === lastSerieIndex - 1) ? 'transparent' : '#DFDFDF'
      },
      onmouseover: function (d) {
        let value = numeral(d.value).format('0.[0]a').toUpperCase()
        let timestamp = Date.parse(d.x)
        countLabel.text(value)
        introLabel.text(getIntroLabel(timestamp))

        elementsToHide.stop().fadeOut(100)
        countLabelLink.toggleClass('DashboardWidget-link--infoOnly')
      },
      onmouseout: function (_d) {
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
 * @param {Object} data
 * @returns {Array}
 */
function timeline (data) {
  let dates = Object.keys(data)
  let x = []
  let y = []

  dates.forEach(date => {
    x.push(moment.utc(date).toISOString())
    y.push(data[date].value)
  })
  return [x, y]
}

function getIntroLabel (timestamp) {
  if (moment().isSame(timestamp, 'day')) {
    return 'today'
  } else {
    return moment(timestamp).format('D MMMM YYYY')
  }
}
