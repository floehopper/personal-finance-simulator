require "test_helper"

class InterestOnlyTrackerLoanTest < Test::Unit::TestCase
  def setup
    @clock = Clock.new
    @amount = Money.parse("100,000.00")
    @lender_account = Account.new
    @borrower_account = Account.new
    term = Term.new(@clock, 25 * 12, 1)
    principal_account = Account.new(@amount)
    @base_rate = InterestRate::Simple.new(4.percent)
    interest_rate = InterestRate::Tracker.new(@base_rate, 2.percent)
    payment_basis = Loan::InterestOnly.new(principal_account, interest_rate, term)
    loan = Loan.new(@lender_account, @borrower_account, principal_account, payment_basis)
    schedule = Loan::Schedule.new(loan, term)
    @expected_low_monthly_payment = Money.parse("500.00")
    @expected_high_monthly_payment = Money.parse("750.00")
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
    151.times { @clock.tick }
    @base_rate.increase_by(3.percent)
    150.times { @clock.tick }
    assert_equal (@expected_low_monthly_payment * 150) + (@expected_high_monthly_payment * 150), @lender_account.balance
    assert_equal(- (@expected_low_monthly_payment * 150) - (@expected_high_monthly_payment * 150), @borrower_account.balance)
  end

end