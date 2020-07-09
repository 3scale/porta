import React, {
  useState,
  FormEventHandler,
  FocusEventHandler,
  useEffect
} from 'react'

import {
  PageSection,
  TextContent,
  Text,
  Card,
  CardBody,
  Form,
  FormGroup,
  TextInput,
  TextArea,
  ActionGroup,
  Button
} from '@patternfly/react-core'
import { useTranslation } from 'i18n/useTranslation'
import { useHistory, Redirect } from 'react-router'
import { createProduct, NewProduct } from 'dal/products'
import { useAsync } from 'react-async'
import { useAlertsContext, useDocumentTitle } from 'components/util'
import { ValidationException, Validator } from 'utils'

type Validations = Record<string, {
  validation: 'default' | 'success' | 'error',
  errors?: string[]
}>

const CreateProductPage = () => {
  const { t } = useTranslation('product')
  useDocumentTitle(t('create.pagetitle'))
  const { goBack } = useHistory()
  const { addAlert } = useAlertsContext()

  const [name, setName] = useState('')
  const [systemName, setSystemName] = useState('')
  const [description, setDescription] = useState('')
  const [validations, setValidations] = useState<Validations>({
    name: { validation: 'default' },
    system_name: { validation: 'default' },
    description: { validation: 'default' }
  })

  const {
    isPending, error, run, data
  } = useAsync({ deferFn: createProduct })

  useEffect(() => {
    if (error) {
      if (Object.prototype.hasOwnProperty.call(error, 'validationErrors')) {
        const { validationErrors } = (error as unknown as ValidationException)
        const newValidations: Validations = {}
        Object.keys(validationErrors).forEach((id) => {
          newValidations[id] = {
            validation: 'error',
            errors: validationErrors[id]
          }
        })
        setValidations({ ...validations, ...newValidations })
      } else {
        addAlert({ id: String(Date.now()), title: error.message, variant: 'danger' })
      }
    }
  }, [error])

  if (data) {
    const { service } = data as NewProduct
    return <Redirect to={`/products/${service.id}`} />
  }

  const isValid = validations.name.validation === 'success' && validations.system_name.validation !== 'error'

  const validator = Validator()
    .for('name', () => (name.length > 0 ? 'success' : 'error'))
    // eslint-disable-next-line no-nested-ternary
    .for('system_name', () => (!systemName ? 'default' : (systemName.length > 0 ? 'success' : 'error')))
    .for('description', () => (description.length > 0 ? 'success' : 'default'))

  const onBlur: FocusEventHandler = (ev) => {
    const { name: inputName } = ev.currentTarget as HTMLInputElement

    const newValidations = { ...validations }

    newValidations[inputName] = {
      validation: validator.validate(inputName)
    }

    setValidations(newValidations)
  }

  const onSubmit: FormEventHandler = (ev) => {
    ev.preventDefault()
    const formData = new FormData(ev.currentTarget as HTMLFormElement)
    run(formData)
  }

  return (
    <>
      <PageSection variant="light">
        <TextContent>
          <Text component="h1">{t('create.bodytitle')}</Text>
        </TextContent>
      </PageSection>

      <PageSection>
        <Card>
          <CardBody>
            <Form onSubmit={onSubmit}>
              <FormGroup
                aria-labelledby="name"
                label={t('create.name')}
                fieldId="name"
                helperTextInvalid={validations.name.errors?.flat()}
                validated={validations.name.validation}
                isRequired
              >
                <TextInput
                  validated={validations.name.validation}
                  id="name"
                  type="text"
                  name="name"
                  value={name}
                  onChange={setName}
                  onBlur={onBlur}
                  isRequired
                />
              </FormGroup>

              <FormGroup
                aria-labelledby="system_name"
                label={t('create.system_name.label')}
                fieldId="system_name"
                helperText={t('create.system_name.helper')}
                helperTextInvalid={validations.system_name.errors?.flat()}
                validated={validations.system_name.validation}
              >
                <TextInput
                  validated={validations.system_name.validation}
                  id="system_name"
                  type="text"
                  name="system_name"
                  value={systemName}
                  onChange={setSystemName}
                  onBlur={onBlur}
                  placeholder={t('create.system_name.placeholder')}
                />
              </FormGroup>

              <FormGroup
                aria-labelledby="description"
                label={t('create.description')}
                fieldId="description"
                helperTextInvalid={validations.description.errors?.flat()}
                validated={validations.description.validation}
              >
                <TextArea
                  validated={validations.description.validation}
                  id="description"
                  name="description"
                  value={description}
                  onChange={setDescription}
                  onBlur={onBlur}
                />
              </FormGroup>

              <ActionGroup>
                <Button
                  aria-label={t('shared:shared_elements.create_button')}
                  type="submit"
                  isDisabled={isPending || !isValid}
                  variant="primary"
                >
                  {t('shared:shared_elements.create_button')}
                </Button>
                <Button
                  aria-label={t('shared:shared_elements.cancel_button')}
                  onClick={goBack}
                  variant="link"
                >
                  {t('shared:shared_elements.cancel_button')}
                </Button>
              </ActionGroup>
            </Form>
          </CardBody>
        </Card>
      </PageSection>
    </>
  )
}

// Default export needed for React.lazy
// eslint-disable-next-line import/no-default-export
export default CreateProductPage
