import moment from 'moment'

const HUMAN_DATE_FORMAT = 'L'

// Period is a necessary evil for Top Applications due the nature of its API.
// It only understands periods of a day, a week, a month and a year.
// Meaning we need to be somehow smart on how selecting this period so then match it with its usage.
// This is why give a date range and granularity, we pick the period that suits it better.
// I.E.: given a user selected state {since: '2015-04-16T08:00:00', until: '2016-04-16T08:00:00', granularity: 'month'}
// then a resulting period will be => year in order to cover the most significative time matching the desire usage.
export function getPeriodFromDateRange (dateRange) {
  let difference = moment(dateRange.until).diff(moment(dateRange.since), dateRange.granularity)
  let granularity = dateRange.granularity
  let selectedRange = moment.duration(difference, granularity)

  switch (granularity) {
    case 'hour':
      if (selectedRange <= moment.duration(24, 'hours')) return 'day'
      else if (selectedRange <= moment.duration(1, 'week')) return 'week'
      else if (selectedRange <= moment.duration(1, 'month')) return 'month'
      else return 'year'
    case 'day':
      if (selectedRange <= moment.duration(1, 'day')) return 'day'
      else if (selectedRange <= moment.duration(1, 'week')) return 'week'
      else if (selectedRange <= moment.duration(1, 'month')) return 'month'
      else return 'year'
    case 'month':
      return (selectedRange > moment.duration(1, 'month')) ? 'year' : granularity
    default:
      return granularity
  }
}

export function humanDateFormat (date) {
  return moment(date).format(HUMAN_DATE_FORMAT)
}
