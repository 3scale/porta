import { applicationDetails } from 'Stats/lib/application_details'

it('should return a weird object', () => {
  const details = applicationDetails({
    total: 100,
    application: {
      id: 11,
      name: 'My Application',
      link: '/p/admin/applications/11',
      service: {
        id: 22
      },
      account: {
        id: 33,
        name: 'My Account',
        link: '/buyers/accounts/33'
      }
    }
  })

  expect(details).toMatchInlineSnapshot(`
    {
      "account": {
        "id": 33,
        "link": "/buyers/accounts/33",
        "name": "My Account",
      },
      "application": {
        "id": 11,
        "link": "/p/admin/applications/11",
        "name": "My Application",
      },
      "total": 100,
    }
  `)
})
