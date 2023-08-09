import Enzyme from 'enzyme'
import Adapter from '@wojtekmaj/enzyme-adapter-react-17'

import $ from 'jquery'
(global as any).jQuery = $

Enzyme.configure({ adapter: new Adapter() })
