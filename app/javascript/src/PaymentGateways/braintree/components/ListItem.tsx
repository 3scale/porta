import { FunctionComponent, PropsWithChildren } from 'react'

type Props = PropsWithChildren<{
  id: string,
}>

const ListItem: FunctionComponent<Props> = ({
  id,
  children
}) => (
  <li
    id={id}
    className="string optional form-group"
  >
    {children}
  </li>
)

export { ListItem, Props }
