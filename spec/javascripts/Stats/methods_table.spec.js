import { StatsMethodsTable } from 'Stats/lib/methods_table'

describe('StatsMethodsTable', () => {
  let methodsTable = new StatsMethodsTable({container: '#methods_table'})

  beforeEach(() => {
    document.body.innerHTML = '<table id="methods_table"></table>'
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

    let table = document.querySelector('table.StatsMethodsTable')
    let nameCell = table.querySelector('.StatsMethodsTable-name')
    let sinceCell = table.querySelector('.StatsMethodsTable-since')
    let untilCell = table.querySelector('.StatsMethodsTable-until')
    let totalCell = table.querySelector('.StatsMethodsTable-total')

    expect(nameCell.innerHTML).toEqual('Charles Bukowski')
    expect(sinceCell.innerHTML).toEqual('16 Aug 1920 00:00:00 PST')
    expect(untilCell.innerHTML).toEqual('09 Mar 1994 00:00:00 PST')
    expect(totalCell.innerHTML).toEqual('42,000')
  })
})
