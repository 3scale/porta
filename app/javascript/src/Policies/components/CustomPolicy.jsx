import React, { useState } from 'react'
import { UnControlled as CodeMirror } from 'react-codemirror2'
import 'codemirror/mode/javascript/javascript'
import Form from 'react-jsonschema-form'

const fromJson = json => JSON.parse(json)
const toJson = val => JSON.stringify(val, null, 2)

// Sample
const schemaSample = {
  title: 'Custom Policy',
  description: 'An epic policy yet to code.',
  type: 'object',
  required: ['name'],
  properties: {
    name: {
      type: 'string',
      title: 'Name',
      default: 'Mashing'
    },
    version: {
      type: 'integer',
      title: 'Version',
      default: 1
    }
  }
}

const cmOptions = {
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

function CustomPolicy () {
  const [schema, setSchema] = useState(schemaSample)

  const onCodeChange = (editor, metadata, code) => {
    setSchema(fromJson(code))
  }

  return (
    <div>
      <CodeMirror
        value={toJson(schema)}
        onChange={onCodeChange}
        autoCursor={false}
        options={cmOptions}
      />
      <Form
        schema={schema}
      >
      </Form>
    </div>
  )
}

export {CustomPolicy}
