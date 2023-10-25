import { render } from 'react-dom'
import {
  Toolbar,
  ToolbarContent,
  ToolbarItem,
  Button
} from '@patternfly/react-core'

import { Pagination } from 'Common/components/Pagination'

import type { FunctionComponent } from 'react'

interface ToolbarAction {
  variant: 'primary';
  label: string;
  href: string;
}

interface Props {
  totalEntries: number;
  rightActions?: ToolbarAction[];
}

const TopToolbar: FunctionComponent<Props> = ({
  totalEntries,
  rightActions
}) => {
  return (
    <Toolbar>
      <ToolbarContent>
        {rightActions && (
          <ToolbarItem alignment={{ default: 'alignRight' }}>
            {rightActions.map(({ variant, label, href }) => (
              <Button key={label} component="a" href={href} variant={variant}>{label}</Button>
            ))}
          </ToolbarItem>
        )}
        <ToolbarItem alignment={{ default: 'alignRight' }} variant="pagination">
          <Pagination itemCount={totalEntries} />
        </ToolbarItem>
      </ToolbarContent>
    </Toolbar>
  )
}

// eslint-disable-next-line react/no-multi-comp
const BottomToolbar: FunctionComponent<{ totalEntries: number }> = ({ totalEntries }) => (
  <Toolbar>
    <ToolbarContent>
      <ToolbarItem alignment={{ default: 'alignRight' }} variant="pagination">
        <Pagination itemCount={totalEntries} />
      </ToolbarItem>
    </ToolbarContent>
  </Toolbar>
)

const ToolbarWrapper = (props: Props, table: HTMLTableElement): void => {
  const top = document.createElement('div')
  const bottom = document.createElement('div')

  table.insertAdjacentElement('beforebegin', top)
  table.insertAdjacentElement('afterend', bottom)

  // eslint-disable-next-line react/jsx-props-no-spreading
  render(<TopToolbar {...props} />, top)
  render(<BottomToolbar totalEntries={props.totalEntries} />, bottom)
}

export type { Props }
export { ToolbarWrapper }
