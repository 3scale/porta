
import type { RegistryPolicy, ThunkAction } from 'Policies/types'

type Props = {
  policy: RegistryPolicy,
  title?: string,
  onClick: () => ThunkAction
}

const PolicyTile: React.FunctionComponent<Props> = ({
  policy,
  onClick,
  title = 'Edit this Policy'
}) => {
  return (
    <article className="Policy-article" title={title} onClick={onClick}>
      <h3 className="Policy-name">{policy.humanName}</h3>
      <p className="Policy-version-and-summary">
        <span>
          {`${policy.version} - ${policy.summary || ''}`}
        </span>
      </p>
    </article>
  )
}

export { PolicyTile, Props }
