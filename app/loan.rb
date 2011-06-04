class Loan

  class InterestOnly

    def initialize(principal_account, rate, term)
      @principal_account, @rate, @term = principal_account, rate, term
    end

    def monthly_interest_payment
      @principal_account.balance * @rate.per_month.to_f
    end

    def monthly_principal_repayment
      Money.empty
    end

    def total_monthly_payment
      monthly_interest_payment + monthly_principal_repayment
    end

  end

  class Repayment < InterestOnly

    def initialize(principal_account, rate, term)
      super
      @rate.add_observer(self)
      update
    end

    def monthly_principal_repayment
      total_monthly_payment - monthly_interest_payment
    end

    def total_monthly_payment
      @total_monthly_payment
    end

    def update
      @total_monthly_payment = monthly_interest_payment / (1 - (1 + @rate.per_month.to_f) ** -@term.in_months)
    end

  end

  class << self
    def interest_only(simulator, lender_account, borrower_account, amount, rate, term)
      build(simulator, lender_account, borrower_account, amount, rate, term, InterestOnly)
    end

    def repayment(simulator, lender_account, borrower_account, amount, rate, term)
      build(simulator, lender_account, borrower_account, amount, rate, term, Repayment)
    end

    private

    def build(simulator, lender_account, borrower_account, amount, rate, term, payment_basis_class)
      principal_account = Account.new(amount)
      payment_basis = payment_basis_class.new(principal_account, rate, term)
      new(simulator, lender_account, borrower_account, principal_account, rate, term, payment_basis)
    end
  end

  def initialize(simulator, lender_account, borrower_account, principal_account, rate, term, payment_basis)
    @simulator, @lender_account, @borrower_account, @principal_account, @rate, @term, @payment_basis = simulator, lender_account, borrower_account, principal_account, rate, term, payment_basis
  end

  def draw_down
    Transfer.new(@lender_account, @borrower_account, @principal_account.balance).complete
    @simulator.schedule_each(1..@term.in_months) { process_monthly_payment }
    @simulator.schedule_in(@term.in_months) { process_principal_repayment }
  end

  def process_monthly_payment
    Transfer.new(@borrower_account, @lender_account, @payment_basis.total_monthly_payment).complete
    @principal_account.debit(@payment_basis.monthly_principal_repayment)
    @term.reduce_months_by(1)
  end

  def process_principal_repayment
    Transfer.new(@borrower_account, @lender_account, @principal_account.balance).complete
  end

end