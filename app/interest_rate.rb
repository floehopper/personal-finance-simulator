require "observer"

module InterestRate

  class Simple

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

  end

  class Tracker < Simple

    def initialize(base_rate, offset_percentage = Percentage.new(0))
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