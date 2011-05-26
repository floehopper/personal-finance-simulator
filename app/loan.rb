require "transfer"
require "duration"

class Loan

  def initialize(simulator, lender, borrower, principal, term, rate)
    @simulator, @lender, @borrower, @principal, @term, @rate = simulator, lender, borrower, principal, term, rate
  end

  def draw_down
    Transfer.new(@lender, @borrower, @principal).complete
    @simulator.schedule_each(1..@term.to_months) { process_monthly_payment }
    @simulator.schedule_in(@term.to_months) { process_principal_repayment }
  end

  def process_monthly_payment
    monthly_interest_payment = (@principal * @rate.to_f / Duration::NUMBER_OF_MONTHS_IN_YEAR)
    Transfer.new(@borrower, @lender, monthly_interest_payment).complete
  end

  def process_principal_repayment
    Transfer.new(@borrower, @lender, @principal).complete
  end

end