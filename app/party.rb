class Party
  def initialize(name, account = Account.new)
    @name, @account = name, account
  end

  def cash_position
    @account.balance
  end
end