// @flow

import * as React from 'react'
import { useState } from 'react'
import SchemaForm from 'react-jsonschema-form'
import { SchemaEditor } from 'Policies/components/SchemaEditor'
import type { Policy, Schema } from 'Policies/types/Policies'
import type {InputEvent} from 'Policies/types'
import 'codemirror/mode/javascript/javascript'
import 'Policies/styles/policies.scss'
import {CSRFToken} from 'utilities/utils'

type OnChange = (InputEvent) => void

const POLICY_TEMPLATE: Policy = {
  schema: {
    '$schema': 'http://apicast.io/policy-v1/schema#manifest#',
    'name': 'Name of the custom policy',
    'summary': 'A one-line (less than 75 characters) summary of what this custom policy does.',
    'description': 'A complete description of what this custom policy does.',
    'version': '0.0.1',
    'configuration': {
      'type': 'object',
      'properties': {
        'property': {
          'description': 'A description of this property',
          'type': 'string'
        }
      }
    }
  },
  directory: '',
  id: 0
}

function CustomPolicyForm ({policy, onChange, win = window}: {policy: Policy, onChange: OnChange, win?: Window}) {
  const isNewPolicy = !policy.id
  const [method, setMethod] = useState(isNewPolicy ? 'post' : 'put')
  const action = (isNewPolicy) ? '/p/admin/registry/policies/' : `/p/admin/registry/policies/${policy.id}`
  const submitText = (isNewPolicy) ? 'Create Custom Policy' : 'Update Policy Schema'

  const deletePolicy = (e) => {
    return win.confirm('Are you sure you want to delete this Policy?')
      ? setMethod('delete')
      : e.preventDefault()
  }

  return (
    <form action={action} method="post" className="formtastic">
      <br/>
      <fieldset className="inputs">
        <legend>Place of the Custom Policy Code</legend>
        <ol>
          <li>
            <label>Path to where the Policy is located in your APIcast installation</label>
            <input placeholder="policy-name/1.0.0/" type="text" name="directory" value={policy.directory} onChange={onChange} />
            <p className="inline-hints">The path to your custom policy relative to <code>APICAST_DIR/policies/</code></p>
          </li>
        </ol>
      </fieldset>
      <input type="hidden" name="id" value={policy.id} disabled={true} />
      <input name="schema" type="hidden" value={JSON.stringify(policy.schema)} />
      <fieldset className="buttons">
        <ol>
          <li className="commit">
            <input type="submit" className="important-button update" value={submitText} />
            <CSRFToken />
          </li>
          {(!isNewPolicy) &&
            (
              <li>
                <div>
                  <input name="_method" type="hidden" value={method} />
                  <button type="submit" className="button-to action delete btn-link" onClick={deletePolicy}>Delete</button>
                </div>
              </li>
            )
          }
        </ol>
      </fieldset>
    </form>
  )
}

function CustomPolicyEditor ({initialPolicy}: {initialPolicy: Policy}) {
  const [policy, setPolicy] = useState(initialPolicy)
  const onSchemaEdited = (schema: Schema) => setPolicy(prevPolicy => ({ ...prevPolicy, ...{ schema } }))
  const handleChange = (ev: InputEvent) => {
    ev.persist()
    return setPolicy(prevPolicy => ({ ...prevPolicy, ...{ [ev.target.name]: ev.target.value } }))
  }

  const schema = policy.schema

  return (
    <div className="CustomPolicyEditor-container">
      <div className="CustomPolicyEditor">
        <SchemaEditor className="SchemaEditor" schema={schema} onChange={onSchemaEdited} />
        <section className="PolicyConfiguration PolicyConfiguration--preview">
          <header className="PolicyConfiguration-header">
            <h2 className="PolicyConfiguration-title">Preview of the Policy Configuration Form</h2>
          </header>
          <h2 className="PolicyConfiguration-name">{schema.name}</h2>
          <p className="PolicyConfiguration-version-and-summary">
            <span className="PolicyConfiguration-version">{schema.version}</span>
            {' - '}
            <span className="PolicyConfiguration-summary">{schema.summary}</span>
          </p>
          <p className="PolicyConfiguration-description">{schema.description}</p>
          <SchemaForm className="SchemaForm" schema={policy.schema.configuration}>
            <button type="submit" className="is-hidden">Submit</button>
          </SchemaForm>
        </section>
      </div>
      <CustomPolicyForm policy={policy} onChange={handleChange} />
    </div>
  )
}

function CustomPolicy ({policy = POLICY_TEMPLATE}: {policy: Policy}) {
  const CANCEL_POLICY_HREF = '/p/admin/registry/policies'
  return (
    <section className="CustomPolicy">
      <header className='CustomPolicy-header'>
        <a className="CustomPolicy-cancel" href={CANCEL_POLICY_HREF} >
          <i className="fa fa-times-circle" /> Cancel
        </a>
      </header>
      <CustomPolicyEditor initialPolicy={policy} />
    </section>
  )
}

export {
  CustomPolicy,
  CustomPolicyForm,
  CustomPolicyEditor,
  POLICY_TEMPLATE
}
