import {
  Button,
  FormGroup,
  InputGroup,
  InputGroupText,
  Spinner,
  TextInput
} from '@patternfly/react-core'
import PencilIcon from '@patternfly/react-icons/dist/js/icons/pencil-alt-icon'
import TrashIcon from '@patternfly/react-icons/dist/js/icons/trash-icon'
import CheckIcon from '@patternfly/react-icons/dist/js/icons/check-icon'
import TimesIcon from '@patternfly/react-icons/dist/js/icons/times-icon'
import { useRef } from 'react'

import { InlineEdit, InlineEditAction, InlineEditGroup } from 'Common/components/InlineEdit'

import type { TextInputProps } from '@patternfly/react-core'
import type { KeyboardEventHandler, RefObject } from 'react'
import type { Product } from 'SiteEmails/types'

interface Props {
  isEditable: boolean;
  product: Product;
  isBeingEdited: boolean;
  onSave: (ref: RefObject<HTMLInputElement>) => void;
  onRemove: (id: number) => void;
  onCancel: (ref: RefObject<HTMLInputElement>) => void;
  onEdit: (exception: Product, ref: RefObject<HTMLInputElement>) => void;
  validated?: TextInputProps['validated'];
  isEditLoading?: boolean;
}

const Exception: React.FunctionComponent<Props> = ({
  product,
  isEditable,
  isBeingEdited,
  onSave,
  onEdit,
  onRemove,
  isEditLoading,
  onCancel,
  validated
}) => {
  const inputRef = useRef<HTMLInputElement>(null)

  const { id, name, supportEmail } = product

  const saveOnEnter: KeyboardEventHandler = ({ key }) => {
    if (key === 'Enter') {
      onSave(inputRef)
    }
  }

  const inlineEditActions = isBeingEdited ? (
    <>
      <InlineEditAction valid>
        <Button
          aria-label={`Save support email for ${name}`}
          icon={isEditLoading ? <Spinner size="md" /> : <CheckIcon />}
          isDisabled={isEditLoading}
          variant="plain"
          onClick={() => { onSave(inputRef) }}
        />
      </InlineEditAction>
      <InlineEditAction>
        <Button
          aria-label={`Cancel edit of support email for ${name}`}
          icon={<TimesIcon />}
          isDisabled={isEditLoading}
          variant="plain"
          onClick={() => { onCancel(inputRef) }}
        />
      </InlineEditAction>
    </>
  ) : (
    <>
      <InlineEditAction>
        <Button
          aria-label={`Edit support email for ${name}`}
          icon={<PencilIcon />}
          isDisabled={!isEditable}
          variant="plain"
          onClick={() => { onEdit(product, inputRef) }}
        />
      </InlineEditAction>
      <InlineEditAction>
        <Button
          aria-label={`Remove support email for ${name}`}
          icon={<TrashIcon />}
          isDisabled={!isEditable}
          variant="plain"
          onClick={() => { onRemove(id) }}
        />
      </InlineEditAction>
    </>
  )

  return (
    <FormGroup>
      <InputGroup>
        <InputGroupText>
          {name}
        </InputGroupText>
        <TextInput
          isRequired
          aria-label={`Support email for ${name}`}
          autoComplete="off"
          defaultValue={supportEmail}
          maxLength={255}
          readOnly={!isBeingEdited}
          ref={inputRef}
          type="email"
          validated={validated}
          onKeyDown={saveOnEnter}
        />
        <InlineEdit>
          <InlineEditGroup>
            {inlineEditActions}
          </InlineEditGroup>
        </InlineEdit>
      </InputGroup>
    </FormGroup>
  )
}

export type { Props }
export { Exception }
