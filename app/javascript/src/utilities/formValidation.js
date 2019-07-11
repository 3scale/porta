/**
 * Ids to state keys
 * Login form: 'session_username', 'session_password'
 * Request password form: 'email'
 * Signup form: 'user_username', 'user_email', 'user_password', 'user_password_confirmation'
 */
const idsToStateKeys = {
  'session_username': 'isValidUsername',
  'session_password': 'isValidPassword',
  'email': 'isValidEmail',
  'user_username': 'isValidUsername',
  'user_email': 'isValidEmailAddress',
  'user_password': 'isValidPassword',
  'user_password_confirmation': 'isValidPasswordConfirmation'
}

const validateFormFields = (formElements) => {
  let formValidated = {
    isValid: false,
    elementsValidity: {}
  }

  const elements = Array.from(
    document.querySelectorAll(formElements.join(','))
  )

  for (let element of elements) {
    formValidated.elementsValidity[idsToStateKeys[element.id]] = element.validity.valid
  }

  const hasPasswordConfirmation = formElements.includes('#user_password_confirmation')
  if (hasPasswordConfirmation) {
    const password = elements.find(elem => elem.id === 'user_password').value
    const passwordConfirmation = elements.find(elem => elem.id === 'user_password_confirmation').value
    formValidated.elementsValidity[idsToStateKeys.user_password_confirmation] = password === passwordConfirmation
  }

  const elementsValidityArray = Array.from(Object.values(formValidated.elementsValidity))

  formValidated.isValid = elementsValidityArray.every(
    (element) => element === true
  )

  return formValidated
}

export { validateFormFields }
