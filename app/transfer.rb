class Transfer
  def initialize(source_party, destination_party, amount)
    @source_party, @destination_party, @amount = source_party, destination_party, amount
  end

  def complete
    @source_party.debit(@amount)
    @destination_party.credit(@amount)
  end
end