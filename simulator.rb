class Simulator
  attr_reader :current_month_index

  def initialize
    @events = Hash.new { |hash, key| hash[key] = [] }
  end

  def at(month_index, &block)
    @events[month_index] << block.to_proc
  end

  def in(number_of_months, &block)
    at(current_month_index + number_of_months, &block)
  end

  def each(month_offsets, &block)
    month_offsets.each do |month_offset|
      self.in(month_offset, &block)
    end
  end

  def play(month_range)
    @current_month_index = month_range.first
    while @current_month_index <= month_range.last do
      @events[@current_month_index].each do |event|
        event.call(@current_month_index)
      end
      @current_month_index += 1
    end
  end
end