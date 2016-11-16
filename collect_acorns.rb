require 'json'
require 'awesome_print'

script_dir= File.absolute_path(File.dirname(__FILE__))

exported_txns= JSON.parse(File.read("#{script_dir}/2016-11-16-exported_transactions.json"))

totals= {}

exported_txns["transactions"].each do |txn|
	next if txn["bookkeeping_type"]=="credit"

	amount= txn["amounts"]["amount"] / 10000.0
	remainder= 1.0-(amount%1.0)

	puts "Enter the goal that \"#{txn["description"]}\" spends from. Alternatively, type \"end\" to sum up."
	goal= gets.chomp
	break if goal=="end"

	puts "#{remainder} => #{goal}"
	totals[goal]||= 0
	totals[goal]+= remainder

	puts
end

ap totals
























