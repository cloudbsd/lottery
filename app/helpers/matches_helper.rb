module MatchesHelper
  def show_float(price)
    number_with_precision(price, precision: 4)
  end
end
