require "test_helper"

class InterestOnlyTrackerLoanTest < Test::Unit::TestCase
  def setup
    @simulator = Simulator.new
    @lender = Party.new("lender")
    @borrower = Party.new("borrower")
    @amount = Money.parse("100,000.00")
    base_rate = InterestRate::Simple.new(Percentage.new(4))
    rate = InterestRate::Tracker.new(base_rate, Percentage.new(2))
    loan = Loan.new(@simulator, @lender, @borrower, @amount, Duration.in_years(25), rate, RepaymentStrategy::InterestOnly)
    @simulator.schedule_at(0) { loan.draw_down }
    @simulator.schedule_at(151) { base_rate.increase_by(Percentage.new(3)) }
    @expected_low_monthly_payment = Money.parse("500.00")
    @expected_high_monthly_payment = Money.parse("750.00")
  end

  def test_draw_down_loan
    @simulator.play(0..0)
    assert_equal -@amount, @lender.cash_position
    assert_equal @amount, @borrower.cash_position
  end

  def test_after_first_monthly_payment
    @simulator.play(0..1)
    assert_equal -@amount + @expected_low_monthly_payment, @lender.cash_position
    assert_equal @amount - @expected_low_monthly_payment, @borrower.cash_position
  end

  def test_after_last_monthly_payment_before_base_rate_rise
    @simulator.play(0..150)
    assert_equal -@amount + (@expected_low_monthly_payment * 150), @lender.cash_position
    assert_equal @amount - (@expected_low_monthly_payment * 150), @borrower.cash_position
  end

  def test_after_first_monthly_payment_after_base_rate_rise
    @simulator.play(0..151)
    assert_equal -@amount + (@expected_low_monthly_payment * 150) + @expected_high_monthly_payment, @lender.cash_position
    assert_equal @amount - (@expected_low_monthly_payment * 150) - @expected_high_monthly_payment, @borrower.cash_position
  end

  def test_after_last_monthly_payment_and_repayment_of_principal
    @simulator.play(0..300)
    assert_equal (@expected_low_monthly_payment * 150) + (@expected_high_monthly_payment * 150), @lender.cash_position
    assert_equal(- (@expected_low_monthly_payment * 150) - (@expected_high_monthly_payment * 150), @borrower.cash_position)
  end

end