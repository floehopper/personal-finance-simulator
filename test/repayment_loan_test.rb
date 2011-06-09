require "test_helper"

class RepaymentLoanTest < Test::Unit::TestCase
  def setup
    @clock = Clock.new
    @amount = Money.parse("100,000.00")
    @lender_account = Account.new
    @borrower_account = Account.new
    term = Term.new(@clock, 25 * 12, 1)
    principal_account = Account.new(@amount)
    interest_rate = InterestRate::Simple.new(6.percent)
    payment_basis = Loan::Repayment.new(principal_account, interest_rate, term)
    loan = Loan.new(@lender_account, @borrower_account, principal_account, payment_basis)
    schedule = Loan::Schedule.new(loan, term)
    @expected_monthly_payment = Money.parse("644.30")
  end

  def test_draw_down_loan
    1.times { @clock.tick }
    assert_equal -@amount, @lender_account.balance
    assert_equal @amount, @borrower_account.balance
  end

  def test_after_first_monthly_payment
    2.times { @clock.tick }
    assert_equal -@amount + @expected_monthly_payment, @lender_account.balance
    assert_equal @amount - @expected_monthly_payment, @borrower_account.balance
  end

  def test_after_second_monthly_payment
    3.times { @clock.tick }
    assert_equal -@amount + (@expected_monthly_payment * 2), @lender_account.balance
    assert_equal @amount - (@expected_monthly_payment * 2), @borrower_account.balance
  end

  def test_after_penultimate_monthly_payment
    300.times { @clock.tick }
    assert_equal -@amount + (@expected_monthly_payment * 299), @lender_account.balance
    assert_equal @amount - (@expected_monthly_payment * 299), @borrower_account.balance
  end

  def test_after_last_monthly_payment_and_repayment_of_principal
    expected_principal_remaining = Money.parse("0.89")
    301.times { @clock.tick }
    assert_equal -@amount + (@expected_monthly_payment * 300) + expected_principal_remaining, @lender_account.balance
    assert_equal @amount - (@expected_monthly_payment * 300) - expected_principal_remaining, @borrower_account.balance
  end

end
