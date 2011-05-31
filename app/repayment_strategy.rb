module RepaymentStrategy

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

  class Standard < InterestOnly

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
      @total_monthly_payment = (@principal_account.balance * @rate.per_month.to_f) / (1 - (1 + @rate.per_month.to_f) ** -@term.in_months)
    end

  end
end