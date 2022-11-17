import { applicationDetails } from 'Stats/lib/application_details'

it('should return a weird object', () => {
  const details = applicationDetails({
    total: 100,
    application: {
      id: 11,
      name: 'My Application',
      service: {
        id: 22
      },
      account: {
        id: 33,
        name: 'My Account'
      }
    }
  })

  expect(details).toMatchInlineSnapshot(`
    Object {
      "account": Object {
        "id": 33,
        "link": "/buyers/accounts/33",
        "name": "My Account",
      },
      "application": Object {
        "id": 11,
        "link": "/apiconfig/services/22/applications/11",
        "name": "My Application",
      },
      "total": 100,
    }
  `)
})
