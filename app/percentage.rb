class Percentage

  module InstanceMethods
    def percent
      Percentage.new(self.to_f)
    end
  end

  attr_reader :number_of_percent
  protected :number_of_percent

  def initialize(number_of_percent)
    @number_of_percent = number_of_percent
  end

  def +(other)
    self.class.new(@number_of_percent + other.number_of_percent)
  end

  def per_month
    self.class.new(@number_of_percent.to_f / Duration::NUMBER_OF_MONTHS_IN_YEAR)
  end

  def to_f
    @number_of_percent.to_f / 100
  end
end

[Bignum, Fixnum, Float, String].each { |klass| klass.send(:include, Percentage::InstanceMethods) }
