// @flow

import * as React from 'react'

import {
  ActionGroup,
  Button,
  Form,
  PageSection,
  PageSectionVariants
} from '@patternfly/react-core'
import { CSRFToken, createReactWrapper } from 'utilities'
import {
  MetricInput,
  PatternInput,
  RedirectUrlInput,
  IncrementByInput,
  IsLastCheckbox,
  PositionInput,
  HttpMethodSelect
} from 'MappingRules'

import type { Metric } from 'Types'

import './NewMappingRule.scss'

type Props = {
  url: string,
  isProxyProEnabled?: boolean,
  topLevelMetrics: Array<Metric>,
  methods: Array<Metric>,
  httpMethods: Array<string>
}

const NewMappingRule = ({ url, isProxyProEnabled = false, topLevelMetrics, methods, httpMethods }: Props): React.Node => {
  const [httpMethod, setHttpMethod] = React.useState(httpMethods[0])
  const [pattern, setPattern] = React.useState('')
  const [metric, setMetric] = React.useState<Metric | null>(null)
  const [redirectUrl, setRedirectUrl] = React.useState('')
  const [increment, setIncrement] = React.useState(1)
  const [isLast, setIsLast] = React.useState(false)
  const [position, setPosition] = React.useState(0)
  const [loading, setLoading] = React.useState(false)

  const isFormComplete = httpMethod &&
    pattern &&
    metric !== null &&
    increment > 0 &&
    position >= 0

  return (
    <PageSection variant={PageSectionVariants.light}>
      <Form
        id="new_mapping_rule"
        acceptCharset="UTF-8"
        method="post"
        action={url}
        onSubmit={e => setLoading(true)}
        // isWidthLimited TODO: use when available instead of hardcoded css
      >
        <CSRFToken />
        <input name="utf8" type="hidden" value="✓" />

        <HttpMethodSelect httpMethod={httpMethod} httpMethods={httpMethods} setHttpMethod={setHttpMethod} />
        <PatternInput pattern={pattern} setPattern={setPattern} />
        {/* $FlowIssue[incompatible-type] Yes it can be null, that's the whole point */}
        <MetricInput metric={metric} topLevelMetrics={topLevelMetrics} methods={methods} setMetric={setMetric} />
        {isProxyProEnabled && <RedirectUrlInput redirectUrl={redirectUrl} setRedirectUrl={setRedirectUrl} />}
        <IncrementByInput increment={increment} setIncrement={setIncrement} />
        <IsLastCheckbox isLast={isLast} setIsLast={setIsLast} />
        <PositionInput position={position} setPosition={setPosition} />

        <ActionGroup>
          <Button
            variant="primary"
            type="submit"
            isDisabled={!isFormComplete || loading}
            data-testid="newMappingRule-buttonSubmit"
          >
            Create Mapping Rule
          </Button>
        </ActionGroup>
      </Form>
    </PageSection>
  )
}

const NewMappingRuleWrapper = (props: Props, containerId: string): void => createReactWrapper(<NewMappingRule {...props} />, containerId)

export { NewMappingRule, NewMappingRuleWrapper }
