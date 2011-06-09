require "test_helper"

class InterestOnlyLoanTest < Test::Unit::TestCase
  def setup
    @clock = Clock.new
    @amount = Money.parse("100,000.00")
    @lender_account = Account.new
    @borrower_account = Account.new
    term = Term.new(@clock, 25 * 12, 1)
    interest_rate = InterestRate.new(6.percent)
    @loan = Loan::InterestOnly.new(@lender_account, @borrower_account, @amount, interest_rate, term)
    @expected_monthly_payment = Money.parse("500.00")
  end

  def test_after_drawing_down_loan
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
    301.times { @clock.tick }
    assert_equal (@expected_monthly_payment * 300), @lender_account.balance
    assert_equal(-(@expected_monthly_payment * 300), @borrower_account.balance)
  end

end
