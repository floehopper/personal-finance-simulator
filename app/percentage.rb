class Percentage
  def initialize(percentage)
    @percentage = percentage
  end

  def per_month
    self.class.new(@percentage.to_f / Duration::NUMBER_OF_MONTHS_IN_YEAR)
  end

  def to_f
    @percentage / 100.0
  end
end