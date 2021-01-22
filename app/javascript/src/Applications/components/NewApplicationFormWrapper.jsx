import React from 'react'

import { NewApplicationForm } from 'Applications'
import { createReactWrapper } from 'utilities/createReactWrapper'

const NewApplicationFormWrapper = (props, containerId) => createReactWrapper(<NewApplicationForm {...props} />, containerId)

export { NewApplicationFormWrapper }
