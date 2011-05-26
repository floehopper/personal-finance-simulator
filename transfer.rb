class Transfer
  def initialize(source_party, destination_party, amount_in_pence)
    @source_party, @destination_party, @amount_in_pence = source_party, destination_party, amount_in_pence
  end

  def complete
    @source_party.debit(@amount_in_pence)
    @destination_party.credit(@amount_in_pence)
  end
end