require "observer"

class InterestRate

  include Observable

  def initialize(initial_percentage)
    @percentage = initial_percentage
  end

  def increase_by(percentage_change)
    unless percentage_change == 0
      @percentage += percentage_change
      changed
      notify_observers
    end
  end

  attr_reader :percentage
  protected :percentage

  def per_month
    percentage.per_month
  end

  class Tracker < InterestRate

    def initialize(base_rate, offset_percentage = 0.percent)
      @base_rate, @offset_percentage = base_rate, offset_percentage
      @base_rate.add_observer(self)
    end

    def percentage
      @base_rate.percentage + @offset_percentage
    end
    protected :percentage

    def update
      changed
      notify_observers
    end

  end

end