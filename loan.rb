require "transfer"

class Loan

  NUMBER_OF_MONTHS_IN_YEAR = 12

  def initialize(simulator, lender, borrower, principal, term_in_months, rate)
    @simulator, @lender, @borrower, @principal, @term_in_months, @rate = simulator, lender, borrower, principal, term_in_months, rate
  end

  def draw_down
    Transfer.new(@lender, @borrower, @principal).complete
    @simulator.each(1..@term_in_months) { process_monthly_payment }
    @simulator.in(@term_in_months) { process_principal_repayment }
  end

  def process_monthly_payment
    monthly_interest_payment = (@principal * @rate / NUMBER_OF_MONTHS_IN_YEAR).round
    Transfer.new(@borrower, @lender, monthly_interest_payment).complete
  end

  def process_principal_repayment
    Transfer.new(@borrower, @lender, @principal).complete
  end

end