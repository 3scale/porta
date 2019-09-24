// @flow

import React from 'react'
import {FormWrapper, ServiceManualListItems} from 'NewService/components/FormElements'
import type {FormProps} from 'NewService/types'
import type {Api} from 'Types/Api'

type Props = {
  formActionPath: string,
  apiap: boolean,
  backendApis: Api[]
}

const ServiceManualForm = (props: Props) => {
  const {formActionPath, apiap} = props

  const formProps: FormProps = {
    id: 'new_service',
    formActionPath,
    submitText: apiap ? 'Create Product' : 'Add API'
  }

  return (
    <FormWrapper {...formProps}>
      <ServiceManualListItems/>
    </FormWrapper>
  )
}

export {
  ServiceManualForm
}
