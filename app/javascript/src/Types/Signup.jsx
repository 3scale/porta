// @flow
import type {FlashMessage} from 'Types'

export type SignupProps = {
  name?: string,
  path: string,
  user: {
    email: string,
    firstname: string,
    lastname: string,
    username: string,
    errors: ?FlashMessage[]
  }
}
