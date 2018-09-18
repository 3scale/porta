import $ from 'jquery'
import {StatsCSVLink} from 'stats/lib/csv_link'

describe('StatsCSVLink', () => {
  let csvLink = new StatsCSVLink({container: '#csv_link'})
  let data = {
    _period: {
      since: '1952-03-11T07:00:00+00:00',
      until: '2001-05-11T07:00:00+00:00',
      timezone: 'Europe/London'
    },
    columns: [
      [
        'x',
        '1952-03-11T07:00:00+00:00',
        '2001-05-11T07:00:00+00:00'
      ],
      [
        'zaphod',
        '12',
        '30'
      ],
      [
        'marvin',
        '11',
        '31'
      ]
    ]
  }
  let expectedCsvString = 'datetime,zaphod,marvin%0A11 Mar 1952 07:00:00 GMT,12,11%0A11 May 2001 08:00:00 BST,30,31'

  beforeEach(() => {
    fixture.set('<div id="csv_link"></div>')
    csvLink.render()
  })

  it('should build correctly the csv string', () => {
    let csvString = csvLink.buildCSVString(data)

    expect(csvString).toBe(expectedCsvString)
  })

  it('should render correctly', () => {
    csvLink.update(data)
    let $link = $('#csv_link').find('a')

    expect($link).toBeInDOM()
    expect($link).toContainText('Download CSV')
    expect($link).toHaveAttr('href', `data:attachment/csv,${expectedCsvString}`)
  })

  it('should throw error if no container was provided', () => {
    let csvLink2 = new StatsCSVLink({container: undefined})
    expect(() => {
      csvLink2.render()
    }).toThrow(new Error('There was no container provided.'))
  })
})
