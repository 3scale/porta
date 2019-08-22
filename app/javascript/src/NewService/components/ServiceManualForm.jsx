// @flow

import React from 'react'
import {BackendApiSelect, FormWrapper, ServiceManualListItems} from 'NewService/components/FormElements'
import type {FormProps} from 'NewService/types'
import type {Api} from 'Types/Api'

type Props = {
  formActionPath: string,
  apiap: boolean,
  backendApis: Api[]
}

const ServiceManualForm = (props: Props) => {
  const {formActionPath, apiap, backendApis} = props

  const formProps: FormProps = {
    id: 'new_service',
    formActionPath,
    submitText: 'Add API'
  }

  return (
    <FormWrapper {...formProps}>
      <ServiceManualListItems/>
      {apiap && <BackendApiSelect backendApis={backendApis} />}
    </FormWrapper>
  )
}

export {
  ServiceManualForm
}
