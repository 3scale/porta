import { transformReportRequestBody } from 'ActiveDocs/ThreeScaleApiDocs'

import type { BackendApiReportBody } from 'Types/SwaggerTypes'

const body: BackendApiReportBody = {
  service_token: 'token',
  service_id: '123',
  transactions: [
    {
      app_id: 'app-id1',
      timestamp: '2023-03-29 00:00:00 -01:00',
      usage: {
        'hit1-1': 11,
        'hit1-2': 12
      },
      log: {
        request: 'request1',
        response: 'response1',
        code: '200'
      }
    },
    {
      app_id: 'app-id2',
      timestamp: '2023-03-29 00:00:00 -02:00',
      usage: {
        'hit2-1': 21,
        'hit2-2': 22
      },
      log: {
        request: 'request2',
        response: 'response2',
        code: '200'
      }
    }
  ]
}

describe('transformReportRequestBody', () => {
  it('transforms the transactions array when transaction is an object', () => {
    const result = transformReportRequestBody(body)

    expect(result).toEqual({
      service_token: 'token',
      service_id: '123',
      'transactions[0][app_id]': 'app-id1',
      'transactions[0][timestamp]': '2023-03-29 00:00:00 -01:00',
      'transactions[0][usage][hit1-1]': 11,
      'transactions[0][usage][hit1-2]': 12,
      'transactions[0][log][request]': 'request1',
      'transactions[0][log][response]': 'response1',
      'transactions[0][log][code]': '200',
      'transactions[1][app_id]': 'app-id2',
      'transactions[1][timestamp]': '2023-03-29 00:00:00 -02:00',
      'transactions[1][usage][hit2-1]': 21,
      'transactions[1][usage][hit2-2]': 22,
      'transactions[1][log][request]': 'request2',
      'transactions[1][log][response]': 'response2',
      'transactions[1][log][code]': '200'
    })
  })
})
