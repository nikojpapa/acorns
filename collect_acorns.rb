require 'json'
require 'awesome_print'
require 'fileutils'

script_dir= File.absolute_path(File.dirname(__FILE__))

@options= {
	:txn_file=> "#{script_dir}/2016-11-16-exported_transactions.json",
	:info_file=> "#{script_dir}/info.json"
}

# OptionParser.new do |opts|
# 	opts.banner= "Usage: collect_acorns.rb [options]"

# 	opts.on("-t", "--txn_file FILE", "Transaction file") do |filename|
# 		@options[:txn_file]= "#{script_dir}/#{filename}"
# 	end
# 	opts.on("-i", "--info_file FILE", "Information file") do |filename|
# 		@options[:info_file]= "#{script_dir}/#{filename}"
# 	end

# end.parse!

exported_txns= JSON.parse(File.read(@options[:txn_file]))
info_file= JSON.parse(File.read(@options[:info_file]))

totals= {}
most_recent_txn= info_file["most_recent_txn"]
new_info= {
	:goal_map=> info_file["goal_map"],
	:most_recent_txn=> most_recent_txn
}
# File.new("test.json", "w")
# File.open("test.json", "w"){|file| file.write(new_info.to_json)}
ap info_file

exported_txns["transactions"].each_with_index do |txn, index|
	#stop if you've hit the most recent transaction
	txn_id= txn["uuid"]
	break if txn_id==most_recent_txn
	next if txn["bookkeeping_type"]=="credit"
	if index==0
		new_info[:most_recent_txn]= txn_id
	end

	#get amount going to acorns
	amount= txn["amounts"]["amount"] / 10000.0
	remainder= 1.0-(amount%1.0)

	#get the goal id and set it if it does not already have a translation
	goal_id= txn["goal_id"]
	if !new_info[:goal_map][goal_id]
		puts "Enter the goal that \"#{txn["description"]}\" spends from."
		new_info[:goal_map][goal_id]= gets.chomp
	end
	goal= new_info[:goal_map][goal_id]
	break if goal=="end"

	totals[goal]||= 0
	totals[goal]+= remainder
end

FileUtils.copy_file(@options[:info_file], "#{@options[:info_file]}.bak")
File.new(@options[:info_file], "w")
File.open(@options[:info_file], "w"){|file| file.write(new_info.to_json)}
ap totals
























