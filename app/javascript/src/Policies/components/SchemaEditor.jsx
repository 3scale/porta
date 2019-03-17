// @flow

import * as React from 'react'
import { useState } from 'react'
import { UnControlled as CodeMirror } from 'react-codemirror2'
import { fromJsonString, toJsonString } from 'Policies/util'
import 'codemirror/mode/javascript/javascript'
import ApicastManifest from 'Policies/apicast-manifest'
import Ajv from 'ajv'
import type { Schema } from 'Policies/types/Policies'

const ajv = new Ajv().addSchema(ApicastManifest, 'ApicastManifest')

const CM_OPTIONS = {
  theme: 'default',
  height: 'auto',
  viewportMargin: Infinity,
  mode: {
    name: 'javascript',
    json: true,
    statementIndent: 2
  },
  lineNumbers: true,
  lineWrapping: true,
  indentWithTabs: false,
  tabSize: 2
}

const validateSchema = (schema: Schema): Array<Error> => {
  return (!ajv.validate('ApicastManifest', schema)) ? ajv.errors : []
}

const initialState = (schema: Schema) => {
  return { errors: validateSchema(schema), code: toJsonString(schema) }
}

function SchemaEditor ({onChange, schema}: {onChange: (Schema) => void, schema: Schema}) {
  const [ state, setState ] = useState(initialState(schema))

  const onCodeChange = (editor, metadata, code) => {
    let errors = []
    try {
      const schema = fromJsonString(code)
      errors = validateSchema(schema)
      if (errors.length === 0) onChange(schema)
    } catch (err) {
      errors = [err]
    }
    setState({errors, code})
  }
  const errors = state.errors
  const [ icon, cls, hiddenClass, errorClass ] = (errors.length === 0)
    ? [ 'check', 'valid', 'is-hidden', '' ]
    : [ 'times', 'invalid', '', 'SchemaEditor-error' ]

  return (
    <div className={`${errorClass} panel panel-default`}>
      <div className="panel-heading">
        <i className={`${cls} fa fa-${icon}`} />
        {' JSON Schema'}
      </div>
      <CodeMirror
        value={state.code}
        onChange={onCodeChange}
        autoCursor={false}
        options={CM_OPTIONS}
      />
      <ul className={hiddenClass}>
        {errors.map((error, index) => <li key={index}>{error.message}</li>)}
      </ul>
    </div>
  )
}

export {
  SchemaEditor,
  CM_OPTIONS
}
