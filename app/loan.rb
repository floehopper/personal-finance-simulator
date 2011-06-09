class Loan

  class Schedule

    def initialize(cashier, term)
      @cashier, @term = cashier, term
      @term.add_observer(self)
    end

    def update
      if @term.first_month?
        @cashier.draw_down
      end
      if @term.in_progress?
        @cashier.pay_monthly_payment
      end
      if @term.last_month?
        @cashier.repay_principal
      end
    end
  end

  module PaymentBasis

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
  end

  class Cashier

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

  class InterestOnly
    def initialize(lender_account, borrower_account, amount, interest_rate, term)
      principal_account = Account.new(amount)
      payment_basis = PaymentBasis::InterestOnly.new(principal_account, interest_rate, term)
      cashier = Cashier.new(lender_account, borrower_account, principal_account, payment_basis)
      @schedule = Schedule.new(cashier, term)
    end
  end

  class Repayment
    def initialize(lender_account, borrower_account, amount, interest_rate, term)
      principal_account = Account.new(amount)
      payment_basis = PaymentBasis::Repayment.new(principal_account, interest_rate, term)
      cashier = Cashier.new(lender_account, borrower_account, principal_account, payment_basis)
      @schedule = Schedule.new(cashier, term)
    end
  end

end