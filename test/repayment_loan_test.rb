require "test_helper"

class RepaymentLoanTest < Test::Unit::TestCase
  def setup
    @simulator = Simulator.new
    @amount = Money.parse("100,000.00")
    @lender_account = Account.new
    @borrower_account = Account.new
    loan = Loan.new(@simulator, @lender_account, @borrower_account, @amount, InterestRate::Simple.new(Percentage.new(6)), Term.in_years(25), RepaymentStrategy::Standard)
    @simulator.schedule_at(0) { loan.draw_down }
    @expected_monthly_payment = Money.parse("644.30")
  end

  def test_draw_down_loan
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
    expected_principal_remaining = Money.parse("0.89")
    @simulator.play(0..300)
    assert_equal -@amount + (@expected_monthly_payment * 300) + expected_principal_remaining, @lender_account.balance
    assert_equal @amount - (@expected_monthly_payment * 300) - expected_principal_remaining, @borrower_account.balance
  end

end
