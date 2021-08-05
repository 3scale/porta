import { StatsApplicationsTable } from 'Stats/lib/applications_table'

describe('StatsApplicationsTable', () => {
  let applicationsTable = new StatsApplicationsTable({ container: '#applications_table' })

  beforeEach(() => {
    document.body.innerHTML = '<table id="applications_table"></table>'
  })

  it('should display the right data on the template', () => {
    applicationsTable.data = [
      {
        account: {
          id: '7',
          name: 'Chino',
          link: '/buyers/account/7'
        },
        application: {
          id: '13',
          name: 'Xiam',
          link: '/apiconfig/services/5/application/13'
        },
        total: 42
      }
    ]
    applicationsTable.render()

    let table = document.querySelector('table#applications_table')
    let application = table.querySelectorAll('.StatsApplicationsTable-application')[0]
    let account = table.querySelectorAll('.StatsApplicationsTable-account')[0]
    let total = table.querySelectorAll('.StatsApplicationsTable-total').[0]

    expect(application.href).toBe(`${window.location.origin}/apiconfig/services/5/application/13`)
    expect(application.innerHTML).toBe('Xiam')
    expect(account.href).toBe(`${window.location.origin}/buyers/account/7`)
    expect(account.innerHTML).toBe('Chino')
    expect(total.innerHTML).toBe('42')
  })
})
