require "rubygems"
require "bundler/setup"

app_path = File.expand_path("../app", __FILE__)
$LOAD_PATH.unshift(app_path)

Dir.glob(File.join(app_path, "*.rb")).each { |f| require f }

require "money"

Money.default_currency = Money::Currency.new("GBP")

class Money
  def -@
    Money.new(-@cents)
  end
end
