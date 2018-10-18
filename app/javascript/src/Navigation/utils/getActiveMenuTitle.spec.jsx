import getActiveMenuTitle from './getActiveMenuTitle'

it('should return the proper title depending on the current menu', () => {
  expect(getActiveMenuTitle('dashboard')).toEqual('Dashboard')

  expect(getActiveMenuTitle('personal')).toEqual('Account')
  expect(getActiveMenuTitle('account')).toEqual('Account')

  expect(getActiveMenuTitle('buyers')).toEqual('Audience')
  expect(getActiveMenuTitle('finance')).toEqual('Audience')
  expect(getActiveMenuTitle('cms')).toEqual('Audience')
  expect(getActiveMenuTitle('site')).toEqual('Audience')
  expect(getActiveMenuTitle('settings')).toEqual('Audience')
  expect(getActiveMenuTitle('audience')).toEqual('Audience')

  expect(getActiveMenuTitle('applications')).toEqual('All APIs')
  expect(getActiveMenuTitle('active_docs')).toEqual('All APIs')

  expect(getActiveMenuTitle('serviceadmin', { service: { name: 'Test' } }))
    .toEqual('API: Test')
  expect(getActiveMenuTitle('monitoring', { service: { name: 'Test' } }))
    .toEqual('API: Test')
})

it('should return a default title', () => {
  expect(getActiveMenuTitle()).toEqual('Choose an API')
})
