require "test_helper"

require "simulator"
require "account"
require "party"
require "loan"

class Fixnum
  def percent
    self / 100.0
  end
end

class LoanTest < Test::Unit::TestCase
  def setup
    @simulator = Simulator.new
    @lender = Party.new("lender", Account.new)
    @borrower = Party.new("borrower", Account.new)
    @loan = Loan.new(@simulator, @lender, @borrower, 10000000, 300, 6.percent)
    @simulator.schedule_at(0) { @loan.draw_down }
  end

  def test_draw_down_loan
    @simulator.play(0..0)
    assert_equal -10000000, @lender.cash_position
    assert_equal +10000000, @borrower.cash_position
  end

  def test_after_first_monthly_payment
    @simulator.play(0..1)
    assert_equal -9950000, @lender.cash_position
    assert_equal +9950000, @borrower.cash_position
  end

  def test_after_second_monthly_payment
    @simulator.play(0..2)
    assert_equal -9900000, @lender.cash_position
    assert_equal +9900000, @borrower.cash_position
  end

  def test_after_penultimate_monthly_payment
    @simulator.play(0..299)
    assert_equal +4950000, @lender.cash_position
    assert_equal -4950000, @borrower.cash_position
  end

  def test_after_last_monthly_payment_and_repayment_of_principal
    @simulator.play(0..300)
    assert_equal +15000000, @lender.cash_position
    assert_equal -15000000, @borrower.cash_position
  end
end
