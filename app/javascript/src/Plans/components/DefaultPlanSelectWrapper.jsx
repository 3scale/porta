// @flow

import React from 'react'
import { DefaultPlanSelectCard } from 'Plans'
import { createReactWrapper } from 'utilities'
import type { Props } from 'Plans/components/DefaultPlanSelectCard'

const DefaultPlanSelectWrapper = (props: Props, containerId: string): void => createReactWrapper(<DefaultPlanSelectCard {...props} />, containerId)

export { DefaultPlanSelectWrapper }
