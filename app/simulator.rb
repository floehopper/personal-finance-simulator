class Simulator
  attr_reader :events

  def initialize
    @current_month_index = 0
    @events = Hash.new { |hash, key| hash[key] = [] }
  end

  def schedule_at(month_index, &block)
    @events[month_index] << block.to_proc
  end

  def schedule_in(number_of_months, &block)
    schedule_at(@current_month_index + number_of_months, &block)
  end

  def schedule_each(month_offsets, &block)
    month_offsets.each do |month_offset|
      schedule_in(month_offset, &block)
    end
  end

  def play(month_range)
    month_range.each do |month_index|
      @current_month_index = month_index
      @events[@current_month_index].each do |event|
        event.call(@current_month_index)
      end
      @current_month_index += 1
    end
  end
end