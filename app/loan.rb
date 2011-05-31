class Loan

  def initialize(simulator, lender_account, borrower_account, amount, rate, term, repayment_strategy_class)
    @simulator, @lender_account, @borrower_account, @rate, @term = simulator, lender_account, borrower_account, rate, term
    @principal_account = Account.new(amount)
    @repayment_strategy = repayment_strategy_class.new(@principal_account, @rate, @term)
  end

  def draw_down
    Transfer.new(@lender_account, @borrower_account, @principal_account.balance).complete
    @simulator.schedule_each(1..@term.in_months) { process_monthly_payment }
    @simulator.schedule_in(@term.in_months) { process_principal_repayment }
  end

  def process_monthly_payment
    Transfer.new(@borrower_account, @lender_account, @repayment_strategy.total_monthly_payment).complete
    @principal_account.debit(@repayment_strategy.monthly_principal_repayment)
    @term.reduce_months_by(1)
  end

  def process_principal_repayment
    Transfer.new(@borrower_account, @lender_account, @principal_account.balance).complete
  end

end