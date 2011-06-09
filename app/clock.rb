require "observer"

class Clock

  include Observable

  def initialize
    reset
  end

  def now
    @month_index
  end

  def tick
    @month_index += 1
    changed
    notify_observers
  end

  def reset
    @month_index = 0
  end
end