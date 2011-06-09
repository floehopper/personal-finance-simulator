class Loan

  class Schedule

    def initialize(loan, term)
      @loan, @term = loan, term
      @term.add_observer(self)
    end

    def update
      if @term.first_month?
        @loan.draw_down
      end
      if @term.in_progress?
        @loan.pay_monthly_payment
      end
      if @term.last_month?
        @loan.repay_principal
      end
    end
  end

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
      @total_monthly_payment = monthly_interest_payment / (1 - (1 + @rate.per_month.to_f) ** -@term.months_remaining)
    end

  end

  def initialize(lender_account, borrower_account, principal_account, payment_basis)
    @lender_account, @borrower_account, @principal_account, @payment_basis = lender_account, borrower_account, principal_account, payment_basis
  end

  def draw_down
    Transfer.new(@lender_account, @borrower_account, @principal_account.balance).complete
  end

  def pay_monthly_payment
    Transfer.new(@borrower_account, @lender_account, @payment_basis.total_monthly_payment).complete
    @principal_account.debit(@payment_basis.monthly_principal_repayment)
  end

  def repay_principal
    Transfer.new(@borrower_account, @lender_account, @principal_account.balance).complete
  end

end