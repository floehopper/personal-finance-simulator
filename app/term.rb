class Term

  NUMBER_OF_MONTHS_IN_YEAR = 12

  class << self
    def in_years(number_of_years)
      new(number_of_years * NUMBER_OF_MONTHS_IN_YEAR)
    end
  end

  def initialize(number_of_months)
    @number_of_months = number_of_months
  end

  def reduce_months_by(number_of_months)
    @number_of_months -= number_of_months
  end

  def in_months
    @number_of_months
  end
end