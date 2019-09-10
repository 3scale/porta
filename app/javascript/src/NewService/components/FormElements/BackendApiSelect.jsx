// @flow

import React from 'react'
import {Label} from 'NewService/components/FormElements'
import type {Api} from 'Types/Api'

type Props = {
  backendApis: Api[]
}

const BackendApiSelect = ({backendApis}: Props) => (
  <li id="service_backend_api_input">
    <Label
      htmlFor='service_backend_api'
      label='Backend API'
    />
    <select name="service[backend_api]" id="service_backend_api">
      <option key='new' value=''>Create a new Backend API</option>
      {backendApis.map(({id, name}) => <option key={id} value={id}>{name}</option>)}
    </select>
  </li>
)

export {BackendApiSelect}
