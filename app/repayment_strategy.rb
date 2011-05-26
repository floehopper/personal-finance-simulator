module RepaymentStrategy

  class InterestOnly

    def initialize(principal, term, rate)
      # intentionally left blank
    end

    def monthly_principal_repayment(monthly_interest_payment)
      Money.empty
    end

  end

  class Standard

    def initialize(principal, term, rate)
      @principal, @term, @rate = principal, term, rate
    end

    def monthly_principal_repayment(monthly_interest_payment)
      total_monthly_payment - monthly_interest_payment
    end

    def total_monthly_payment
      (@principal * @rate.per_month.to_f) / (1 - (1 + @rate.per_month.to_f) ** -@term.to_months)
    end

  end
end