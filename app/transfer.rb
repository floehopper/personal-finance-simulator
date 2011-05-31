class Transfer
  def initialize(source_account, destination_account, amount)
    @source_account, @destination_account, @amount = source_account, destination_account, amount
  end

  def complete
    @source_account.debit(@amount)
    @destination_account.credit(@amount)
  end
end