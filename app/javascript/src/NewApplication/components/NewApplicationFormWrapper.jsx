import React from 'react'

import { NewApplicationForm } from 'NewApplication'
import { createReactWrapper } from 'utilities'

const NewApplicationFormWrapper = (props, containerId) => createReactWrapper(<NewApplicationForm {...props} />, containerId)

export { NewApplicationFormWrapper }
