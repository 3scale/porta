import { StatsMethodsTable } from 'Stats/lib/methods_table'

describe('StatsMethodsTable', () => {
  let methodsTable = new StatsMethodsTable({container: '#methods_table'})

  beforeEach(() => {
    fixture.set('<table id="methods_table"></table>')
  })

  it('should display the right data on the template', () => {
    methodsTable.data = [
      {
        name: 'Charles Bukowski',
        total: 42000,
        period: {
          since: '1920-08-16T00:00:00-08:00',
          until: '1994-03-09T00:00:00-08:00',
          timezone: 'America/Los_Angeles'
        }
      }
    ]
    methodsTable.render()

    let $table = $('table.StatsMethodsTable')
    let $nameCell = $table.find('.StatsMethodsTable-name').first()
    let $sinceCell = $table.find('.StatsMethodsTable-since').first()
    let $untilCell = $table.find('.StatsMethodsTable-until').first()
    let $totalCell = $table.find('.StatsMethodsTable-total').first()

    expect($nameCell).toContainText('Charles Bukowski')
    expect($sinceCell).toContainText('16 Aug 1920 00:00:00 PST')
    expect($untilCell).toContainText('09 Mar 1994 00:00:00 PST')
    expect($totalCell).toContainText('42,000')
  })
})
