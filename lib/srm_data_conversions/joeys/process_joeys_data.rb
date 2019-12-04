require 'csv'

# Assumes the data from the spreadsheets has merged into one file

class ProcessJoeysData
	# csv input columns
	ID            = 'ID'
	SPOUSE_ID     = 'SpouseID'
	FLAG_TYPE     = 'Constit'
	SURNAME       = 'Surname'
	NAME          = 'Preferred'
	SPOUSE_NAME   = 'SpousePreferred'
	EMAILS        = 'DefaultEmail'
	PHONE         = 'DefaultMobilePhone'
	EMAILS_OPTION = 'EmailsOption'

	# csv supporter output columns
	JOEYS_ID   = 'id'
	FIRST_NAME = 'first_name'
	LAST_NAME  = 'last_name'
	EMAIL      = 'email'
	LAND_PHONE = 'home_phone'
	MOBILE     = 'mobile_phone'
	SRM_FLAG   = 'srm_flag'
	NOTES      = 'notes'
	
	# csv relationship output columns
	FROM_ID    = 'from_id'
	TO_ID      = 'to_id'

	# Multiple emails option.  Default is to use 2nd email for primary supporter
	USE_FIRST = 'first' # Use first email for primary supporter
	SPLIT     = 'split' # Split emails between primary & spouse
	EMAIL_OPTIONS = [USE_FIRST, SPLIT]

	# Joeys flag_type to SRM_flag conversion
	SRM_FLAGS = {
		'OldBoy'            => 'OLD_BOY'          , 
		'OldBoySpouse'      => 'OLD_BOY_SPOUSE'   , 
		'Current Parent'    => 'CURRENT_PARENT'   ,
		'Past Parent'       => 'PAST_PARENT'      ,
		'Friend of College' => 'FRIEND_OF_COLLEGE',
	}

	def initialize(in_joeys_data:, out_supporters_csv:, out_relationships_csv:)
		@in_joeys_data         = in_joeys_data
		@out_supporters_csv    = out_supporters_csv
		@out_relationships_csv = out_relationships_csv
		@supporters    = {}       # { joeys_id : { joeys supporter data }}
		@relationships = {}       # { joeys_id : other_joeys_id }
	end

	def convert_data
		puts "===== Reading/processing ====="
		CSV.foreach(@in_joeys_data, headers: true).with_index do |row, i|
			print '.'
			create_or_update_supporter(row)
			create_or_update_spouse(row)
			update_relationships_data(row)
		end
		puts "\n===== Writing supporters (#{@supporters.count}) & relationships (#{@relationships.count}) ====="
		write_csvs
		puts "===== Done! ====="
	end

	def create_or_update_supporter(row)
		primary_supporter = setup_primary_supporter(row)
		existing_supporter = @supporters[primary_supporter[JOEYS_ID]]  # hash of hashes keyed by joeys supporter id

		if existing_supporter # must be spouse of another supporter
			existing_supporter[LAND_PHONE] = primary_supporter[LAND_PHONE]
			existing_supporter[MOBILE]     = primary_supporter[MOBILE]
			if primary_supporter[EMAIL]
				if existing_supporter[EMAIL] # if existing supporter has an email, add existing email as a note
					existing_supporter[NOTES] << alternate_email_note(existing_supporter[EMAIL])
				end
				existing_supporter[EMAIL] = primary_supporter[EMAIL] # update existing supporter email
			end
			existing_supporter[NOTES] << primary_supporter[NOTES] if primary_supporter[NOTES]
			@supporters[existing_supporter[JOEYS_ID]] = existing_supporter # update
		else
			@supporters[primary_supporter[JOEYS_ID]] = primary_supporter # create
		end
	end

	def setup_primary_supporter(row)
		emails = clean_email_array(row[EMAILS])
		email, note = supporter_email_decide(emails, row[EMAILS_OPTION]) 
		land_phone, mobile = phone_decide(clean_phone(row[PHONE]))

		{
			JOEYS_ID   => row[ID],
			FIRST_NAME => row[NAME],
			LAST_NAME  => row[SURNAME],
			EMAIL      => email,
			LAND_PHONE => land_phone,
			MOBILE     => mobile,
			SRM_FLAG   => SRM_FLAGS[row[FLAG_TYPE]],
			NOTES      => note ? [note] : []
		}
	end

	def clean_phone(phone)
		phone = phone&.gsub(/[a-zA-Z]/, '')&.strip  # strip and remove a-zA-Z
		phone == '' ? nil : phone
	end

	def phone_decide(phone)
		return [nil, nil] unless phone

		mobile, land_phone = nil, nil
		phone[0..1] == '04' ? mobile = phone : land_phone = phone
		[land_phone, mobile]
	end

	def clean_email_array(email)
		return [] unless email
		emails = email.split(';').each { |e| e.strip! }  # returns an array of stripped emails
		emails.uniq    # remove any duplicates
	end

	def supporter_email_decide(emails, special_multi_email_option)
		return [nil, nil]       if emails.count == 0
		return [emails[0], nil] if emails.count == 1

		case special_multi_email_option
		when USE_FIRST
			[emails[0], alternate_email_note(emails[1])]
		when SPLIT
			[emails[0], nil]
		else # default = use 2nd email
			[emails[1], alternate_email_note(emails[0])]
		end
	end
	
	def alternate_email_note(email)
		"Alternate Email: #{email}"
	end

	def create_or_update_spouse(row)
		return unless row[SPOUSE_ID] && row[SPOUSE_NAME]

		supporter_spouse   = setup_supporter_spouse(row)
		existing_supporter = @supporters[supporter_spouse[SPOUSE_ID]]  # hash of hashes keyed by joeys supporter id

		if existing_supporter
			if supporter_spouse[EMAIL]
				if existing_supporter[EMAIL] # Keep existing and put spouse in note
					existing_supporter[NOTES] << alternate_email_note(supporter_spouse[EMAIL]) if existing_supporter[EMAIL] != supporter_spouse[EMAIL]
				else
					existing_supporter[EMAIL] = supporter_spouse[EMAIL]
				end
				@supporters[existing_supporter[JOEYS_ID]] = existing_supporter # update
		  end
		else
			@supporters[supporter_spouse[JOEYS_ID]] = supporter_spouse   # create
		end
	end

	def setup_supporter_spouse(row)
		emails = clean_email_array(row[EMAILS])
		email  = spouse_email_decide(emails, row[EMAILS_OPTION])

		srm_flag = SRM_FLAGS[row[FLAG_TYPE]] == 'OLD_BOY' ? 'OLD_BOY_SPOUSE' : SRM_FLAGS[row[FLAG_TYPE]]

		{
			JOEYS_ID   => row[SPOUSE_ID],
			FIRST_NAME => row[SPOUSE_NAME],
			LAST_NAME  => row[SURNAME],
			EMAIL      => email,
			LAND_PHONE => nil,
			MOBILE     => nil,
			SRM_FLAG   => srm_flag,
			NOTES      => []
		}
	end

	def spouse_email_decide(emails, special_multi_email_option)
		return nil unless emails.count == 2 && special_multi_email_option == SPLIT
		emails[1] # Splitting means use 2nd email for spouse
	end

	def update_relationships_data(row)
		return unless row[SPOUSE_ID] && row[SPOUSE_ID] != '0' && row[SPOUSE_NAME]

		# Use the highest ID value as the key to avoid duplicates
		high_id, low_id = row[ID] > row[SPOUSE_ID] ? [row[ID], row[SPOUSE_ID]] : [row[SPOUSE_ID], row[ID]]
		unless @relationships[high_id] # ignore if exists
			@relationships[high_id] = low_id # create
		end
	end

	def write_csvs
		write_supporter_csv
		write_relationships_csv
	end

	def write_supporter_csv
		File.delete(@out_supporters_csv) if File.exists?(@out_supporters_csv)
		CSV.open(@out_supporters_csv, "w") do |csv|
			csv << [JOEYS_ID, FIRST_NAME, LAST_NAME, EMAIL, LAND_PHONE, MOBILE, SRM_FLAG, NOTES] # header row
			@supporters.each do |key, s|
				notes = s[NOTES].count > 0 ? s[NOTES].join(', ') : nil
				csv << [s[JOEYS_ID], s[FIRST_NAME], s[LAST_NAME], s[EMAIL], s[LAND_PHONE], s[MOBILE], s[SRM_FLAG], notes]
			end
		end
	end

	def write_relationships_csv
		File.delete(@out_relationships_csv) if File.exists?(@out_relationships_csv)
		CSV.open(@out_relationships_csv, "w") do |csv|
			csv << [FROM_ID, TO_ID] # header row
			@relationships.each { |key, value| csv << [key, value] }
		end
	end

	def show_problems
		show_multiple_emails
		show_weird_phones
		show_bad_srm_flags
		puts "===== That's it for problems! ====="
	end

	def show_multiple_emails
		puts "===== Checking for Multiple Emails ====="
		count = 0
		CSV.foreach(@in_joeys_data, headers: true).with_index do |row, i|
			emails = clean_email_array(row[EMAILS])
			if row[EMAILS]&.include?(';')
				emails = row[EMAILS].strip.split(';')
				count += 1
				special = if emails.count > 2
										'*** MoreThan2 ***'
									elsif emails.count == 1
										'*** Only1 ***'
									else
										nil
									end
				special2 = nil
				if row[EMAILS_OPTION]
					special2 = EMAIL_OPTIONS.include?(row[EMAILS_OPTION].strip) ? "*** Option=#{row[EMAILS_OPTION]} ***" : "*** Option #{row[EMAILS_OPTION]} not found in [#{EMAIL_OPTIONS.join(', ')}]!!! ***"
				end
				puts "count=#{count} | i=#{i} | row[SURNAME]=#{row[SURNAME]} | row[NAME]=#{row[NAME]} | row[SPOUSE_NAME]=#{row[SPOUSE_NAME]} | row[EMAILS]=#{row[EMAILS]} | #{special} #{special2}"
			end
		end
	end

	def show_weird_phones
		puts "===== Checking for Weird Phones ====="
		count = 0
		CSV.foreach(@in_joeys_data, headers: true).with_index do |row, i|
			puts "i=#{i} | row[PHONE]=#{row[PHONE]} | *** has a ; ***" if row[PHONE]&.include?(';')
			if clean_phone(row[PHONE]) != row[PHONE]&.strip 
				count += 1
			  puts "count=#{count} | i=#{i} | row[PHONE]=#{row[PHONE]} | clean_phone(row[PHONE])=#{clean_phone(row[PHONE])}"
			end
		end
	end

	def show_bad_srm_flags
		puts "===== Checking for bad SRM flags ====="
		count = 0
		CSV.foreach(@in_joeys_data, headers: true).with_index do |row, i|
			if SRM_FLAGS[row[FLAG_TYPE]] == nil
				count += 1
				puts "count=#{count} | i=#{i} | flag #{row[FLAG_TYPE]} not found in #{SRM_FLAGS}"
			end
		end
	end
end

processor = ProcessJoeysData.new(in_joeys_data: 'JoeysDataMerged.csv', out_supporters_csv: 'JoeysSupporters.csv', out_relationships_csv: 'JoeysRelationships.csv')
processor.show_problems

continue = ''
loop do
	print "Continue with data conversion (y/n)? "
	continue = gets.chomp
	break if 'yn'.include?(continue)
end
processor.convert_data if continue == 'y'
