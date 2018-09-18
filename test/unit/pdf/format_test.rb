require 'test_helper'

class Pdf::FormatTest < ActiveSupport::TestCase

  test 'prep_td' do
   assert_equal [ "<td>abc</td>", "<td>def</td>" ], Pdf::Format.prep_td(['abc','def'])
   assert_equal [ "<td>1</td>", "<td>2</td>" ], Pdf::Format.prep_td([1,2])
  end
end
