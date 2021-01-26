import React from 'react'

import { DefaultPlanSelector } from 'Applications'
import { createReactWrapper } from 'utilities/createReactWrapper'

const DefaultPlanSelectorWrapper = (props, containerId) => createReactWrapper(<DefaultPlanSelector {...props} />, containerId)

export { DefaultPlanSelectorWrapper }
