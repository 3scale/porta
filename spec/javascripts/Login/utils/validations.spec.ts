import {
  validateLogin,
  validateChangePassword,
  validateSignup,
  validateRequestPassword
} from 'Login/utils/validations'

describe('#validateLogin', () => {
  it('should work', () => {
    expect(validateLogin({
      username: '',
      password: ''
    })).not.toBeUndefined()

    expect(validateLogin({
      username: 'pepe',
      password: ''
    })).not.toBeUndefined()

    expect(validateLogin({
      username: '',
      password: '****'
    })).not.toBeUndefined()

    expect(validateLogin({
      username: 'pepe',
      password: '****'
    })).toBeUndefined()
  })
})

describe('#validateChangePassword', () => {
  it('should work', () => {
    expect(validateChangePassword({
      password: '',
      passwordConfirmation: ''
    })).not.toBeUndefined()

    expect(validateChangePassword({
      password: 'aaaaaa',
      passwordConfirmation: ''
    })).not.toBeUndefined()

    expect(validateChangePassword({
      password: '',
      passwordConfirmation: 'aaaaaa'
    })).not.toBeUndefined()

    expect(validateChangePassword({
      password: 'aaaaaa',
      passwordConfirmation: 'aaaaaa'
    })).not.toBeUndefined()

    expect(validateChangePassword({
      password: 'superSecret1234#',
      passwordConfirmation: ''
    })).not.toBeUndefined()

    expect(validateChangePassword({
      password: '',
      passwordConfirmation: 'superSecret1234#'
    })).not.toBeUndefined()

    expect(validateChangePassword({
      password: 'superSecret1234#',
      passwordConfirmation: 'superSecret1234#'
    })).toBeUndefined()
  })
})

describe('#validateSignup', () => {
  it('should work', () => {
    expect(validateSignup({
      username: '',
      firstName: '',
      lastName: '',
      email: '',
      password: '',
      passwordConfirmation: ''
    })).not.toBeUndefined()

    expect(validateSignup({
      username: '',
      firstName: '',
      lastName: '',
      email: 'pepe@example.com',
      password: 'superSecret1234#',
      passwordConfirmation: 'superSecret1234#'
    })).not.toBeUndefined()

    expect(validateSignup({
      username: 'pepe',
      firstName: '',
      lastName: '',
      email: '',
      password: 'superSecret1234#',
      passwordConfirmation: 'superSecret1234#'
    })).not.toBeUndefined()

    expect(validateSignup({
      username: 'pepe',
      firstName: '',
      lastName: '',
      email: 'pepe@example.com',
      password: 'superSecret1234#',
      passwordConfirmation: 'superSecret1234#'
    })).toBeUndefined()
  })
})

describe('#validateRequestPassword', () => {
  it('should work', () => {
    expect(validateRequestPassword('123')).not.toBeUndefined()
    expect(validateRequestPassword('pepeexample.com')).not.toBeUndefined()
    expect(validateRequestPassword('@example.com')).not.toBeUndefined()
    expect(validateRequestPassword('pepe@example.com')).toBeUndefined()
  })
})
