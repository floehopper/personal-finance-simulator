require "test_helper"

class RepaymentTrackerLoanTest < Test::Unit::TestCase
  def setup
    @simulator = Simulator.new
    @amount = Money.parse("100,000.00")
    @lender_account = Account.new
    @borrower_account = Account.new
    base_rate = InterestRate::Simple.new(4.percent)
    rate = InterestRate::Tracker.new(base_rate, 2.percent)
    loan = Loan.new(@simulator, @lender_account, @borrower_account, @amount, rate, Term.in_years(25), PaymentCalculator::Repayment)
    @simulator.schedule_at(0) { loan.draw_down }
    @simulator.schedule_at(151) { base_rate.increase_by(3.percent) }
    @expected_low_monthly_payment = Money.parse("644.30")
    @expected_high_monthly_payment = Money.parse("755.33")
  end

  def test_draw_down_loan
    @simulator.play(0..0)
    assert_equal -@amount, @lender_account.balance
    assert_equal @amount, @borrower_account.balance
  end

  def test_after_first_monthly_payment
    @simulator.play(0..1)
    assert_equal -@amount + @expected_low_monthly_payment, @lender_account.balance
    assert_equal @amount - @expected_low_monthly_payment, @borrower_account.balance
  end

  def test_after_monthly_payment_immediately_before_base_rate_rise
    @simulator.play(0..150)
    assert_equal -@amount + (@expected_low_monthly_payment * 150), @lender_account.balance
    assert_equal @amount - (@expected_low_monthly_payment * 150), @borrower_account.balance
  end

  def test_after_monthly_payment_immediately_after_base_rate_rise
    @simulator.play(0..151)
    assert_equal -@amount + (@expected_low_monthly_payment * 150) + @expected_high_monthly_payment, @lender_account.balance
    assert_equal @amount - (@expected_low_monthly_payment * 150) - @expected_high_monthly_payment, @borrower_account.balance
  end

  def test_after_last_monthly_payment_and_repayment_of_principal
    expected_principal_remaining = Money.parse("0.94")
    @simulator.play(0..300)
    assert_equal -@amount + (@expected_low_monthly_payment * 150) + (@expected_high_monthly_payment * 150) + expected_principal_remaining, @lender_account.balance
    assert_equal @amount - (@expected_low_monthly_payment * 150) - (@expected_high_monthly_payment * 150) - expected_principal_remaining, @borrower_account.balance
  end

end