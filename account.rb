class Account
  attr_reader :balance

  def initialize(initial_balance = Money.empty)
    @balance = initial_balance
  end

  def debit(amount)
    @balance -= amount
  end

  def credit(amount)
    @balance += amount
  end
end
