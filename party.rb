class Party
  attr_reader :account

  def initialize(name, account)
    @name, @account = name, account
  end
end