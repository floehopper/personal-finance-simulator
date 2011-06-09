require File.expand_path("../../environment", __FILE__)

data = []

number_of_months_renting = 12
monthly_rent = Money.parse("1,000.00")

clock = Clock.new
scheduler = Scheduler.new(clock)
lender_account = Account.new
borrower_account = Account.new
term = Term.new(clock, Duration.in_years(22), 1)
base_rate = InterestRate.new(0.5.percent)
interest_rate = InterestRate::Tracker.new(base_rate, 0.35.percent)
loan = Loan::Repayment.new(lender_account, borrower_account, Money.parse("220,000.00"), interest_rate, term)

data[0] = []
scheduler.schedule_each(1..number_of_months_renting) { borrower_account.debit(monthly_rent) }
scheduler.schedule_each(1..Duration.in_years(25).in_months) { data[0] << [clock.now, borrower_account.balance.to_f] }
301.times { clock.tick }


clock = Clock.new
scheduler = Scheduler.new(clock)
lender_account = Account.new
borrower_account = Account.new
principal_acccount = Account.new(Money.parse("220,000.00"))
term = Term.new(clock, Duration.in_years(22) - Duration.new(number_of_months_renting), number_of_months_renting)
interest_rate = InterestRate.new(3.5.percent)
loan = Loan::Repayment.new(lender_account, borrower_account, Money.parse("220,000.00"), interest_rate, term)

data[1] = []
scheduler.schedule_each(1..number_of_months_renting) { borrower_account.debit(monthly_rent) }
scheduler.schedule_each(1..Duration.in_years(25).in_months) { data[1] << [clock.now, borrower_account.balance.to_f] }
301.times { clock.tick }

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
