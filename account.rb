class Account
  attr_reader :balance

  def initialize(initial_balance_in_pence = 0)
    @balance = initial_balance_in_pence
  end

  def debit(amount)
    @balance -= amount
  end

  def credit(amount)
    @balance += amount
  end
end
