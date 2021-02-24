// @flow

import React from 'react'
import { DefaultPlanSelect } from 'Plans'
import { createReactWrapper } from 'utilities/createReactWrapper'
import type { Props } from 'Plans/components/DefaultPlanSelect'

const DefaultPlanSelectWrapper = (props: Props, containerId: string) => createReactWrapper(<DefaultPlanSelect {...props} />, containerId)

export { DefaultPlanSelectWrapper }
