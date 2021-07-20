import { StatsApplicationsTable } from 'Stats/lib/applications_table'
import $ from 'jquery'

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

    let $table = $('table#applications_table')
    let $application = $table.find('.StatsApplicationsTable-application').first()
    let $account = $table.find('.StatsApplicationsTable-account').first()
    let $total = $table.find('.StatsApplicationsTable-total').first()

    expect($application.prop('href')).toBe(`${window.location.origin}/apiconfig/services/5/application/13`)
    expect($application.text()).toBe('Xiam')
    expect($account.prop('href')).toBe(`${window.location.origin}/buyers/account/7`)
    expect($account.text()).toBe('Chino')
    expect($total.text()).toBe('42')
  })
})
