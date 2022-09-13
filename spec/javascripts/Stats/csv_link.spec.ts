import { StatsCSVLink } from 'Stats/lib/csv_link'

describe('StatsCSVLink', () => {
  const csvLink = new StatsCSVLink({ container: '#csv_link' })
  const data = {
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
  const expectedCsvString = 'datetime,zaphod,marvin%0A11 Mar 1952 07:00:00 GMT,12,11%0A11 May 2001 08:00:00 BST,30,31'

  beforeEach(() => {
    document.body.innerHTML = '<div id="csv_link"></div>'
    csvLink.render()
  })

  it('should build correctly the csv string', () => {
    const csvString = csvLink.buildCSVString(data)

    expect(csvString).toBe(expectedCsvString)
  })

  it('should render correctly', () => {
    csvLink.update(data)
    const link = document.querySelector('#csv_link').querySelector('a')

    expect(link).toBeDefined()
    expect(link.innerHTML).toEqual('Download CSV')
    expect(link.href).toBe(`data:attachment/csv,${expectedCsvString}`)
  })

  it('should throw error if no container was provided', () => {
    const csvLink2 = new StatsCSVLink({ container: undefined })
    expect(() => {
      csvLink2.render()
    }).toThrow(new Error('There was no container provided.'))
  })
})
