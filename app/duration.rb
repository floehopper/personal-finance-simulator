class Duration

  NUMBER_OF_MONTHS_IN_YEAR = 12

  class << self
    def in_years(number_of_years)
      new(number_of_years * NUMBER_OF_MONTHS_IN_YEAR)
    end
  end

  def initialize(number_of_months)
    @number_of_months = number_of_months
  end

  def to_months
    @number_of_months
  end
end