class Party
  def initialize(name, account)
    @name, @account = name, account
  end

  def credit(amount_in_pence)
    @account.credit(amount_in_pence)
  end

  def debit(amount_in_pence)
    @account.debit(amount_in_pence)
  end

  def cash_position
    @account.balance
  end
end