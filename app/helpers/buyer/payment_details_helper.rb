module Buyer::PaymentDetailsHelper
  def month_names_with_numbers
    [
      '1 - January', '2 - February', '3 - March', '4 - April', '5 - May', '6 - June',
      '7 - July', '8 - August', '9 - September', '10 - October', '11 - November',
      '12 - December'
    ]
  end

  def next_fifteen_years
    Time.zone.now.year..(Time.zone.now + 15.years).year
  end
end
