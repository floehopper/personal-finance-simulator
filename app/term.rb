require "observer"

class Term

  include Observable

  def initialize(clock, duration, starts_at)
    @clock, @duration, @starts_at = clock, duration, starts_at
    @clock.add_observer(self)
  end

  def finishes_at
    @starts_at + @duration.in_months
  end

  def first_month?
    @clock.now == @starts_at
  end

  def months_remaining
    [finishes_at - @clock.now, @duration.in_months].min
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