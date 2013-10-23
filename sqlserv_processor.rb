results = []
file = File.open("sql_server_schema.txt", "r").each do |line| 
	line.encode!('UTF-8', 'UTF-8', :invalid => :replace)
	results << line
end

out_file = File.open("processed_schema.txt", "w")

new_results = []	
w = 0	
results.each do |line|
	if line[/^(CREATE TABLE)/]
		w = 1	
	end

	if line[/^(GO)/]
		w = 0	
	end	
	
	if w == 1
		out_file.puts line	
	end
end

out_file.close


#SECONDARY FILE PROCESSING

results = []
file = File.open("processed_schema.txt", "r").each do |line|
	results << line
end

out_file = File.open("schema.rb", "w")
out_file_2 = File.open("table_list.rb", "w")

is_beginning = 0

results.each do |line|	
	line[/(NOT NULL)/] ? can_be_null = ":null => false" : nil
	
	if line[/^(CREATE TABLE)/]	

		if is_beginning == 1
			out_file.puts "  end"
			out_file.puts	
		else
			is_beginning = 1		
		end	
	
		table = line[/\.\[\w+\]/][2..-2]
		table[-1] == "s" ? nil : add_s = "s"	
		out_file.puts "  create_table \"#{table}#{add_s}\", :force => true do |t|"
		out_file_2.puts "  create_table \"#{table}#{add_s}\", :force => true do |t|"

	
	elsif line[/(int\])/]	
		col = line[/\[(\w+)/][1..-1]
		out_file.puts "		t.integer	\"#{col}\",			#{can_be_null}"
		
	elsif line[/(char\])/] 
		col = line[/\[(\w+)/][1..-1]
		out_file.puts "		t.string	\"#{col}\",			#{can_be_null}"

	elsif line[/(decimal\])/]
		col = line[/\[(\w+)/][1..-1]
		out_file.puts "		t.decimal	\"#{col}\",			#{can_be_null}"

	elsif line[/(numeric\])/]
		col = line[/\[(\w+)/][1..-1]
		out_file.puts "		t.decimal	\"#{col}\",			#{can_be_null}"

	elsif line[/(datetime)/]
		col = line[/\[(\w+)/][1..-1]
		out_file.puts "		t.datetime \"#{col}\",		#{can_be_null}"



	#else
	#	out_file.puts line
	end	
end



	
