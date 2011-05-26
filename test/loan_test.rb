require "test_helper"

require "simulator"
require "account"
require "party"
require "loan"
require "duration"
require "percentage"

class LoanTest < Test::Unit::TestCase
  def setup
    @simulator = Simulator.new
    @lender = Party.new("lender", Account.new)
    @borrower = Party.new("borrower", Account.new)
    @loan = Loan.new(@simulator, @lender, @borrower, Money.parse("100,000.00"), Duration.in_years(25), Percentage.new(6))
    @simulator.schedule_at(0) { @loan.draw_down }
  end

  def test_draw_down_loan
    @simulator.play(0..0)
    assert_equal Money.parse("-100,000.00"), @lender.cash_position
    assert_equal Money.parse("+100,000.00"), @borrower.cash_position
  end

  def test_after_first_monthly_payment
    @simulator.play(0..1)
    assert_equal Money.parse("-99,500.00"), @lender.cash_position
    assert_equal Money.parse("+99,500.00"), @borrower.cash_position
  end

  def test_after_second_monthly_payment
    @simulator.play(0..2)
    assert_equal Money.parse("-99,000.00"), @lender.cash_position
    assert_equal Money.parse("+99,000.00"), @borrower.cash_position
  end

  def test_after_penultimate_monthly_payment
    @simulator.play(0..299)
    assert_equal Money.parse("+49,500.00"), @lender.cash_position
    assert_equal Money.parse("-49,500.00"), @borrower.cash_position
  end

  def test_after_last_monthly_payment_and_repayment_of_principal
    @simulator.play(0..300)
    assert_equal Money.parse("+150,000.00"), @lender.cash_position
    assert_equal Money.parse("-150,000.00"), @borrower.cash_position
  end
end
