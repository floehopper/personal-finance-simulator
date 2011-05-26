require "rubygems"
require "bundler/setup"

require "test/unit"

require "active_support"
require "money"

Money.default_currency = Money::Currency.new("GBP")

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "app"))