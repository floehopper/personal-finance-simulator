require "transfer"
require "duration"

class Loan

  def initialize(simulator, lender, borrower, principal, term, rate, repayment_strategy)
    @simulator, @lender, @borrower, @principal, @term, @rate, @repayment_strategy = simulator, lender, borrower, principal, term, rate, repayment_strategy.new(principal, term, rate)
  end

  def draw_down
    Transfer.new(@lender, @borrower, @principal).complete
    @owed = @principal
    @simulator.schedule_each(1..@term.to_months) { process_monthly_payment }
    @simulator.schedule_in(@term.to_months) { process_principal_repayment }
  end

  def process_monthly_payment
    interest_payment = @owed * @rate.per_month.to_f
    principal_repayment = @repayment_strategy.monthly_principal_repayment(interest_payment)
    @owed -= principal_repayment
    Transfer.new(@borrower, @lender, principal_repayment + interest_payment).complete
  end

  def process_principal_repayment
    Transfer.new(@borrower, @lender, @owed).complete
  end

end