class Percentage
  def initialize(percentage)
    @percentage = percentage
  end

  def to_f
    @percentage / 100.0
  end
end