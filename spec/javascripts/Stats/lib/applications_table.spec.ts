import { StatsApplicationsTable } from 'Stats/lib/applications_table'

describe('StatsApplicationsTable', () => {
  const applicationsTable = new StatsApplicationsTable({ container: '#applications_table' })

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

    const table = document.querySelector('table#applications_table') as Element
    const application = table.querySelectorAll<HTMLAnchorElement>('.StatsApplicationsTable-application')[0]
    const account = table.querySelectorAll<HTMLAnchorElement>('.StatsApplicationsTable-account')[0]
    // TODO: how did this line ever get to master?
    // let total = table.querySelectorAll('.StatsApplicationsTable-total').[0]
    const total = table.querySelectorAll('.StatsApplicationsTable-total')[0]

    expect(application.href).toBe(`${window.location.origin}/apiconfig/services/5/application/13`)
    expect(application.innerHTML).toBe('Xiam')
    expect(account.href).toBe(`${window.location.origin}/buyers/account/7`)
    expect(account.innerHTML).toBe('Chino')
    expect(total.innerHTML).toBe('42')
  })
})
