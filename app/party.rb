require "account"

class Party
  def initialize(name, account = Account.new)
    @name, @account = name, account
  end

  def credit(amount)
    @account.credit(amount)
  end

  def debit(amount)
    @account.debit(amount)
  end

  def cash_position
    @account.balance
  end
end