require "transfer"

class Loan

  NUMBER_OF_MONTHS_IN_YEAR = 12

  def initialize(simulator, lender, borrower, principal_in_pence, term_in_months, rate)
    @simulator, @lender, @borrower, @principal_in_pence, @term_in_months, @rate = simulator, lender, borrower, principal_in_pence, term_in_months, rate
  end

  def draw_down
    Transfer.new(@lender, @borrower, @principal_in_pence).complete
    @simulator.schedule_each(1..@term_in_months) { process_monthly_payment }
    @simulator.schedule_in(@term_in_months) { process_principal_repayment }
  end

  def process_monthly_payment
    monthly_interest_payment = (@principal_in_pence * @rate / NUMBER_OF_MONTHS_IN_YEAR).round
    Transfer.new(@borrower, @lender, monthly_interest_payment).complete
  end

  def process_principal_repayment
    Transfer.new(@borrower, @lender, @principal_in_pence).complete
  end

end