import React from 'react'

import { DefaultPlanSelect } from 'Applications'
import { createReactWrapper } from 'utilities/createReactWrapper'

const DefaultPlanSelectWrapper = (props, containerId) => createReactWrapper(<DefaultPlanSelect {...props} />, containerId)

export { DefaultPlanSelectWrapper }
