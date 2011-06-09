require "test_helper"

class RepaymentTrackerLoanTest < Test::Unit::TestCase
  def setup
    @clock = Clock.new
    @amount = Money.parse("100,000.00")
    @lender_account = Account.new
    @borrower_account = Account.new
    term = Term.new(@clock, 25 * 12, 1)
    @base_rate = InterestRate.new(4.percent)
    interest_rate = InterestRate::Tracker.new(@base_rate, 2.percent)
    @loan = Loan::Repayment.new(@lender_account, @borrower_account, @amount, interest_rate, term)
    @expected_low_monthly_payment = Money.parse("644.30")
    @expected_high_monthly_payment = Money.parse("755.33")
  end

  def test_draw_down_loan
    1.times { @clock.tick }
    assert_equal -@amount, @lender_account.balance
    assert_equal @amount, @borrower_account.balance
  end

  def test_after_first_monthly_payment
    2.times { @clock.tick }
    assert_equal -@amount + @expected_low_monthly_payment, @lender_account.balance
    assert_equal @amount - @expected_low_monthly_payment, @borrower_account.balance
  end

  def test_after_monthly_payment_immediately_before_base_rate_rise
    151.times { @clock.tick }
    assert_equal -@amount + (@expected_low_monthly_payment * 150), @lender_account.balance
    assert_equal @amount - (@expected_low_monthly_payment * 150), @borrower_account.balance
  end

  def test_after_monthly_payment_immediately_after_base_rate_rise
    151.times { @clock.tick }
    @base_rate.increase_by(3.percent)
    1.times { @clock.tick }
    assert_equal -@amount + (@expected_low_monthly_payment * 150) + @expected_high_monthly_payment, @lender_account.balance
    assert_equal @amount - (@expected_low_monthly_payment * 150) - @expected_high_monthly_payment, @borrower_account.balance
  end

  def test_after_last_monthly_payment_and_repayment_of_principal
    expected_principal_remaining = Money.parse("0.94")
    151.times { @clock.tick }
    @base_rate.increase_by(3.percent)
    150.times { @clock.tick }
    assert_equal -@amount + (@expected_low_monthly_payment * 150) + (@expected_high_monthly_payment * 150) + expected_principal_remaining, @lender_account.balance
    assert_equal @amount - (@expected_low_monthly_payment * 150) - (@expected_high_monthly_payment * 150) - expected_principal_remaining, @borrower_account.balance
  end

end