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

type Error = {
  [string]: Array<string>
}

type Props = {
  url: string,
  isProxyProEnabled?: boolean,
  topLevelMetrics: Array<Metric>,
  methods: Array<Metric>,
  httpMethods: Array<string>,
  errors?: Error
}

type Validated = 'success' | 'warning' | 'error' | 'default'

const NewMappingRule = ({ url, isProxyProEnabled = false, topLevelMetrics, methods, httpMethods, errors }: Props): React.Node => {
  const [httpMethod, setHttpMethod] = React.useState(httpMethods[0])
  const [pattern, setPattern] = React.useState('')
  const [patternValidated, setPatternValidated] = React.useState<Validated>('default')
  const [helperTextInvalid, setHelperTextInvalid] = React.useState('')
  const [metric, setMetric] = React.useState<Metric | null>(null)
  const [redirectUrl, setRedirectUrl] = React.useState('')
  const [increment, setIncrement] = React.useState(1)
  const [isLast, setIsLast] = React.useState(false)
  const [position, setPosition] = React.useState(0)
  const [loading, setLoading] = React.useState(false)

  React.useEffect(() => {
    if (errors && errors.pattern) {
      setPatternValidated('error')
      setHelperTextInvalid(errors.pattern.slice().join())
    }
  }, [])

  const validatePattern = (value, _event) => {
    setPattern(value)
    setPatternValidated('default')
  }

  const isFormComplete = httpMethod &&
    pattern &&
    patternValidated !== 'error' &&
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
        <PatternInput pattern={pattern} validatePattern={validatePattern} validated={patternValidated} helperTextInvalid={helperTextInvalid}/>
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
            Create mapping rule
          </Button>
        </ActionGroup>
      </Form>
    </PageSection>
  )
}

const NewMappingRuleWrapper = (props: Props, containerId: string): void => createReactWrapper(<NewMappingRule {...props} />, containerId)

export { NewMappingRule, NewMappingRuleWrapper }
