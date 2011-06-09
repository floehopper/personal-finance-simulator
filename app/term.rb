require "observer"

class Term

  NUMBER_OF_MONTHS_IN_YEAR = 12

  include Observable

  # class << self
  #   def in_years(number_of_years)
  #     new(number_of_years * NUMBER_OF_MONTHS_IN_YEAR)
  #   end
  # end

  def initialize(clock, number_of_months, starts_at)
    @clock, @number_of_months, @starts_at = clock, number_of_months, starts_at
    @clock.add_observer(self)
  end

  def finishes_at
    @starts_at + @number_of_months
  end

  def first_month?
    @clock.now == @starts_at
  end

  def months_remaining
    [finishes_at - @clock.now, @number_of_months].min
  end

  def in_progress?
    (@clock.now > @starts_at) && (@clock.now <= finishes_at)
  end

  def last_month?
    @clock.now == finishes_at
  end

  def update
    changed
    notify_observers
  end

end