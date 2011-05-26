require "test_helper"

require "simulator"
require "party"
require "loan"
require "duration"
require "percentage"
require "repayment_strategy"

class RepaymentLoanTest < Test::Unit::TestCase
  def setup
    @simulator = Simulator.new
    @lender = Party.new("lender")
    @borrower = Party.new("borrower")
    @amount = Money.parse("100,000.00")
    loan = Loan.new(@simulator, @lender, @borrower, @amount, Duration.in_years(25), Percentage.new(6), RepaymentStrategy::Standard)
    @simulator.schedule_at(0) { loan.draw_down }
    @expected_monthly_payment = Money.parse("644.30")
  end

  def test_draw_down_loan
    @simulator.play(0..0)
    assert_equal -@amount, @lender.cash_position
    assert_equal @amount, @borrower.cash_position
  end

  def test_after_first_monthly_payment
    @simulator.play(0..1)
    assert_equal -@amount + @expected_monthly_payment, @lender.cash_position
    assert_equal @amount - @expected_monthly_payment, @borrower.cash_position
  end

  def test_after_second_monthly_payment
    @simulator.play(0..2)
    assert_equal -@amount + (@expected_monthly_payment * 2), @lender.cash_position
    assert_equal @amount - (@expected_monthly_payment * 2), @borrower.cash_position
  end

  def test_after_penultimate_monthly_payment
    @simulator.play(0..299)
    assert_equal -@amount + (@expected_monthly_payment * 299), @lender.cash_position
    assert_equal @amount - (@expected_monthly_payment * 299), @borrower.cash_position
  end

  def test_after_last_monthly_payment_and_repayment_of_principal
    @simulator.play(0..300)
    assert_equal -@amount + (@expected_monthly_payment * 300), @lender.cash_position
    assert_equal @amount - (@expected_monthly_payment * 300), @borrower.cash_position
  end

end
