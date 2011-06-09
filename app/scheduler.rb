class Scheduler

  class Schedule

    def initialize(clock, month_indices, &block)
      @clock, @month_indices, @block = clock, month_indices, block
      @clock.add_observer(self)
    end

    def update
      if @month_indices.include?(@clock.now)
        @block.call
      end
    end

  end

  def initialize(clock)
    @clock, @schedules = clock, []
  end

  def schedule_each(month_indices, &block)
    @schedules << Schedule.new(@clock, month_indices, &block)
  end

end