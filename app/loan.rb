class Loan

  def initialize(simulator, lender, borrower, principal, term, rate, repayment_strategy_class)
    @simulator, @lender, @borrower, @principal, @term, @rate, @repayment_strategy_class = simulator, lender, borrower, principal, term, rate, repayment_strategy_class
  end

  def draw_down
    Transfer.new(@lender, @borrower, @principal).complete
    @owed = @principal
    @remaining_term = @term
    update
    @rate.add_observer(self)
    @simulator.schedule_each(1..@term.to_months) { process_monthly_payment }
    @simulator.schedule_in(@term.to_months) { process_principal_repayment }
  end

  def process_monthly_payment
    interest_payment = @owed * @rate.per_month.to_f
    principal_repayment = @repayment_strategy.monthly_principal_repayment(interest_payment)
    @owed -= principal_repayment
    @remaining_term -= 1
    Transfer.new(@borrower, @lender, principal_repayment + interest_payment).complete
  end

  def process_principal_repayment
    Transfer.new(@borrower, @lender, @owed).complete
  end

  def update
    @repayment_strategy = @repayment_strategy_class.new(@owed, @remaining_term, @rate)
  end

end