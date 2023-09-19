import { isNotApicastPolicy } from 'Policies/util'
import { PolicyTile } from 'Policies/components/PolicyTile'

import type { RegistryPolicy, ThunkAction } from 'Policies/types'

interface Props {
  items: RegistryPolicy[];
  actions: {
    addPolicy: (policy: RegistryPolicy) => ThunkAction;
    closePolicyRegistry: () => ThunkAction;
  };
}

const PolicyRegistry: React.FunctionComponent<Props> = ({
  items,
  actions: { addPolicy }
}) => (
  <section className="PolicyRegistry">
    <ul className="list-group">
      {items.filter(isNotApicastPolicy).map(p => (
        <li key={p.name} className="Policy">
          <PolicyTile policy={p} title="Add this Policy" onClick={() => addPolicy(p)} />
        </li>
      ))}
    </ul>
  </section>
)

export type { Props }
export { PolicyRegistry }
