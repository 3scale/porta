import { objectToFormData, transformReportRequestBody } from 'ActiveDocs/ThreeScaleApiDocs'

import type { BackendApiReportBody, BackendApiTransaction, BodyValue } from 'Types/SwaggerTypes'

const transaction1: BackendApiTransaction = {
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
}
const transaction2: BackendApiTransaction = {
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
const body: BackendApiReportBody = {
  service_token: 'token',
  service_id: '123',
  transactions: [
    transaction1,
    transaction2
  ]
}

describe('objectToFormData', () => {
  it('transforms the object to form data', () => {
    const object: BodyValue = {
      number: 1,
      string: 'string with whitespace',
      object: {
        numField: 2,
        strField: 'str',
        boolField: true
      },
      array: [
        {
          foo: 'bar'
        },
        {
          foo: 'baz'
        }
      ],
      nullField: null,
      undefinedField: undefined,
      emptyField: ''
    }

    expect(objectToFormData(object)).toEqual({
      number: 1,
      string: 'string with whitespace',
      'object[numField]': 2,
      'object[strField]': 'str',
      'object[boolField]': true,
      'array[0][foo]': 'bar',
      'array[1][foo]': 'baz',
      nullField: '',
      undefinedField: '',
      emptyField: ''
    })
  })

  it('returns an empty object if argument is not a valid object', () => {
    expect(objectToFormData('hello')).toEqual({})
    expect(objectToFormData(true)).toEqual({})
    expect(objectToFormData(123)).toEqual({})
    expect(objectToFormData(['q', 'w', 'r'])).toEqual({})
  })

})

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

  it('transforms the transactions array when a transaction is a serialized JSON', () => {
    const bodyWithSerializedTransaction = {
      ...body,
      transactions: [
        transaction1,
        '{\n  "app_id": "app-id2",\n  "timestamp": "2023-03-29 00:00:00 -02:00",\n  "usage": {\n    "hit2-1": 21,\n    "hit2-2": 22\n  },\n  "log": {\n    "request": "request2",\n    "response": "response2",\n    "code": "200"\n  }\n}']
    }
    const result = transformReportRequestBody(bodyWithSerializedTransaction)

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

  it('skips the transactions with invalid format', () => {
    const bodyWithInvalidTransactions = {
      ...body,
      transactions: [transaction1, 'invalid', 'anotherOne']
    }
    const consoleErrorMock = jest.spyOn(console, 'error').mockImplementation()

    const result = transformReportRequestBody(bodyWithInvalidTransactions)
    expect(result).toEqual({
      service_token: 'token',
      service_id: '123',
      'transactions[0][app_id]': 'app-id1',
      'transactions[0][timestamp]': '2023-03-29 00:00:00 -01:00',
      'transactions[0][usage][hit1-1]': 11,
      'transactions[0][usage][hit1-2]': 12,
      'transactions[0][log][request]': 'request1',
      'transactions[0][log][response]': 'response1',
      'transactions[0][log][code]': '200'
    })

    expect(consoleErrorMock).toHaveBeenCalledTimes(2)
    consoleErrorMock.mockRestore()
  })
})
