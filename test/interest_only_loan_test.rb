require "test_helper"

class InterestOnlyLoanTest < Test::Unit::TestCase
  def setup
    @simulator = Simulator.new
    @amount = Money.parse("100,000.00")
    @lender_account = Account.new
    @borrower_account = Account.new
    loan = Loan.interest_only(@simulator, @lender_account, @borrower_account, @amount, InterestRate::Simple.new(6.percent), Term.in_years(25))
    @simulator.schedule_at(0) { loan.draw_down }
    @expected_monthly_payment = Money.parse("500.00")
  end

  def test_after_drawing_down_loan
    @simulator.play(0..0)
    assert_equal -@amount, @lender_account.balance
    assert_equal @amount, @borrower_account.balance
  end

  def test_after_first_monthly_payment
    @simulator.play(0..1)
    assert_equal -@amount + @expected_monthly_payment, @lender_account.balance
    assert_equal @amount - @expected_monthly_payment, @borrower_account.balance
  end

  def test_after_second_monthly_payment
    @simulator.play(0..2)
    assert_equal -@amount + (@expected_monthly_payment * 2), @lender_account.balance
    assert_equal @amount - (@expected_monthly_payment * 2), @borrower_account.balance
  end

  def test_after_penultimate_monthly_payment
    @simulator.play(0..299)
    assert_equal -@amount + (@expected_monthly_payment * 299), @lender_account.balance
    assert_equal @amount - (@expected_monthly_payment * 299), @borrower_account.balance
  end

  def test_after_last_monthly_payment_and_repayment_of_principal
    @simulator.play(0..300)
    assert_equal (@expected_monthly_payment * 300), @lender_account.balance
    assert_equal(-(@expected_monthly_payment * 300), @borrower_account.balance)
  end

end
