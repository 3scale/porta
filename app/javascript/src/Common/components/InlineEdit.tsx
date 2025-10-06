/* eslint-disable react/no-multi-comp */
import React from 'react'

/**
 * These components does not exist in Patternfly React 4.
 * Source: http://v4-archive.patternfly.org/v4/components/inline-edit/
 */

const InlineEdit: React.FunctionComponent<{ children: React.ReactNode }> = ({ children }) => (
  <div className="pf-c-inline-edit pf-m-inline-editable">{children}</div>
)

const InlineEditGroup: React.FunctionComponent<{ children: React.ReactNode }> = ({ children }) => (
  <div className="pf-c-inline-edit__group pf-m-action-group pf-m-icon-group">{children}</div>
)

const InlineEditAction: React.FunctionComponent<{ children: React.ReactNode; valid?: boolean }> = ({ children, valid }) => (
  <div className={`pf-c-inline-edit__action${valid ? ' pf-m-valid' : ''}`}>{children}</div>
)

export { InlineEdit, InlineEditGroup, InlineEditAction }
