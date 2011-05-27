module InterestRate

  class Simple

    def initialize(initial_percentage)
      @percentage = initial_percentage
    end

    def increase_by(percentage)
      @percentage += percentage
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
    end

    def percentage
      @base_rate.percentage + @offset_percentage
    end
    protected :percentage

  end

end