import { StatsApplicationsTable } from 'stats/lib/applications_table'

describe('StatsApplicationsTable', () => {
  let applicationsTable = new StatsApplicationsTable({container: '#applications_table'})

  beforeEach(() => {
    fixture.set('<table id="applications_table"></table>')
  })

  it('should display the right data on the template', () => {
    applicationsTable.data = [
      {
        account: {
          id: '7',
          name: 'Chino',
          link: '/buyer/account/7'
        },
        application: {
          id: '13',
          name: 'Xiam',
          link: '/buyer/application/13'
        },
        total: 42
      }
    ]
    applicationsTable.render()

    let $table = $('table#applications_table')
    let $application = $table.find('.StatsApplicationsTable-application').first()
    let $account = $table.find('.StatsApplicationsTable-account').first()
    let $total = $table.find('.StatsApplicationsTable-total').first()

    expect($application).toHaveProp('href', `${window.location.origin}/buyer/application/13`)
    expect($application).toContainText('Xiam')
    expect($account).toHaveProp('href', `${window.location.origin}/buyer/account/7`)
    expect($account).toContainText('Chino')
    expect($total).toContainText('42')
  })
})
