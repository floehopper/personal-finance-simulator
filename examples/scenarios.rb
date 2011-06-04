require File.expand_path("../../environment", __FILE__)

data = []

number_of_months_renting = 12
monthly_rent = Money.parse("1,000.00")

simulator = Simulator.new
lender_account = Account.new
borrower_account = Account.new
base_rate = InterestRate::Simple.new(0.5.percent)
interest_rate = InterestRate::Tracker.new(base_rate, 0.35.percent)
loan = Loan.repayment(simulator, lender_account, borrower_account, Money.parse("220,000.00"), interest_rate, Term.in_years(22))

data[0] = []
simulator.schedule_at(0) { loan.draw_down }
simulator.schedule_each(0...number_of_months_renting) { borrower_account.debit(monthly_rent) }
simulator.play(0..300) do |month_index|
  data[0] << [month_index, borrower_account.balance.to_f]
end


simulator = Simulator.new
lender_account = Account.new
borrower_account = Account.new
interest_rate = InterestRate::Simple.new(3.5.percent)
term = Term.in_years(22)
term.reduce_months_by(number_of_months_renting)
loan = Loan.repayment(simulator, lender_account, borrower_account, Money.parse("220,000.00"), interest_rate, term)

data[1] = []
simulator.schedule_each(0...number_of_months_renting) { borrower_account.debit(monthly_rent) }
simulator.schedule_at(number_of_months_renting) { loan.draw_down }
simulator.play(0..300) do |month_index|
  data[1] << [month_index, borrower_account.balance.to_f]
end

def flot_path(filename)
  File.expand_path("../../flot/#{filename}", __FILE__)
end

require "erb"
template = File.open(flot_path("plot.html.erb")).read
html = ERB.new(template).result

output_path = flot_path("scenarios.html")
File.open(output_path, "w") do |file|
  file.write(html)
end
`open #{output_path}`
