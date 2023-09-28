import React from 'react'

const FakeForm = (props) => {
  const { formData, ...rest } = props
  return <form {...rest} />
}

export default FakeForm
