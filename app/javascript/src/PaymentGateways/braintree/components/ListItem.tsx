import type { FunctionComponent, PropsWithChildren } from 'react'

type Props = PropsWithChildren<{
  id: string,
}>

const ListItem: FunctionComponent<Props> = ({
  id,
  children
}) => (
  <li
    className="string optional form-group"
    id={id}
  >
    {children}
  </li>
)

export { ListItem, Props }
