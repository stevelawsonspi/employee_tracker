require 'csv'
load 'duplicates/supporters_for_attributes.rb'
load 'duplicates/supporters_for_attributes_with_datetime.rb'

class DMImport

	FILE = {
		'DMI Supporters 2019-09-13.csv' => {
			# 'Status',
			# 'Last Name',
			# 'First Name',
			# 'Greeting',
			# 'Address 1',
			# 'Address 2',
			# 'City',
			# 'State',
			# 'Postcode',
			# 'Phone',
			# 'Comments',
			# 'NL Qty',
			# 'Send NL?',
			# 'Deleted',
			# 'SupporterID',
			# 'Country',

			import: false,
			dedupe: true,
			drop_if: {
				"Deleted" => "1",
			},
			mappings: {
				interaction: {
					datetime: :early_interaction,
				},
				supporter: {
					prefix: 'Status',
					# email: 'Email',
					id: 'SupporterID',
					first_name: 'First Name',
					last_name: 'Last Name',
					unknown_phone: ['Phone'],
				},
				note: {
					value: 'Comments',
				},
				address: {
					line_1: 'Address 1',
					line_2: 'Address 2',
					city: 'City',
					state: 'State',
					postcode: 'Postcode',
					country: 'Country',
					_type: 'HOME',
				},
				flags: {
					preference: {
						# do_not_email: 'Email_Opt_Out',
						newsletter: 'Send NL?'
					},
					country: {
						_: 'Country',
					}
				},
			},
		},
		'By Sponsor MASTER 2019-SEPT.csv' => {

			# 'Student Surname',
			# 'St Given Name',
			# 'School',
			# 'Sponsor Surname',
			# 'Sponsor Given Name',
			# 'Country',
			# '2019',
			# '2018',
			# '2014',
			# '2015',
			# '2016',
			# '2017',
			# '2018',
			# '2019',
			# 'Sponsor Address 1',
			# 'Sponsor Address 2',
			# 'Sponsor Email',
			# 'Start',
			# 'Notes',

			import: true,
			dedupe: true,
			preprocessor: :extract_schools,
			drop_if: {
				'Student Surname' => ['NEWSLETTER', 'SUPPORTER', 'SCHOOL SPON', 'Past Sponsor', 'SPEC PROJECT'],
				'St Given Name' => ['EMAIL NEWS', 'PROJ MANAGEMT'],
				'School' => 'Schools',
			},
			mappings: {
				interaction: {
					date: "Start",
					parser: '%Y-%m'
				},
				supporter: {
					last_name: 'Student Surname',
					first_name: 'St Given Name',
				},
				relationships: {
					sponsor: {
						first_name: 'Sponsor Given Name',
						last_name: 'Sponsor Surname',
						email: 'Sponsor Email',
					}
				},
				group_membership: {
					group_type_name: 'SCHOOL', # actual type name
					group_name: 'School', # column name
				}
			},
		},
	}
end

# ----------------------------------

class DMImport

	def initialize
		# @base_dir = "/home/aidan/Desktop/aaa_data"
		@base_dir = "/tmp"
		@type_lk = {}
		@flag_name_lk = {}
		@files = FILE
		@assume_nsw = true
		@default_tz = 'Australia/Sydney'
	end

	def interaction(row, conf, _, _)
		datetime = if conf[:datetime] == :early_interaction
			'1970-01-01 00:00:00 +0000'
		elsif conf[:datetime]
			Time.use_zone(@default_tz) do
				Time.zone.parse row[conf[:datetime]]
			end
		elsif conf[:date]
			DateTime.strptime row[conf[:date]], conf[:parser]
		else
			raise "Error parsing date"
		end

		interaction = Interactions::Data::History::Interaction.new(
			datetime: datetime,
			type: 'CLI',
			source: 'EMPLOYEE',
			target: 'SYSTEM',
			description: 'Initial data import',
			audit_user_identifier: 'aidan.samuel@supporterhub.com',
		).save or raise interaction.errors.to_s
		interaction
	end

	def external_id(row, conf, interaction, supporter)
		puts "external_id not implemented"
	end

	def extract_schools(rows)
		schools = rows.map { |r| r['School'].try :strip }.compact.sort.uniq - ['Schools']
		puts "Creating Schools: #{schools}"

		schools.map do |school|
			supporter = Supporters::Data::State::Supporter.new(
				group_name: school,
				group_type_state_uuid: Reference::Data::State::GroupType.first!(name: "SCHOOL").state_uuid,
				interaction: origin_interaction,
			)
			supporter.save or raise supporter.errors.to_s
			supporter
		end
	end

	def supporter(row, conf, interaction, _)
		data = {interaction: interaction}

		row.values_at(*conf[:unknown_phone]).select { |x| /\d/ === x }.each do |phone_number|
			pn = phone_number.gsub(/^['MHW]:? */, '')
			npn = pn.gsub /[^\+\d]/, ''
			pn = "0#{pn}" if /^4\d{8}/ === npn
			pn = "+#{pn}" if /^61\d{9}/ === npn

			case row['State']
			when /^(NSW|ACT)$/i
				pn = "02#{pn}" if /^[3-9]\d{7}/ === npn
			when /^(VIC|TAS)$/i
				pn = "03#{pn}" if /^[3-9]\d{7}/ === npn
			when /^(QLD)$/i
				pn = "07#{pn}" if /^[2-57]\d{7}/ === npn
			when /^(SA|NT|WA)$/i
				pn = "08#{pn}" if /^[25-9]\d{7}/ === npn
			end

			case Supporters::ValidatePhoneNumber.new(pn).type
			when :landline, :international
				data[:home_phone] = pn
			when :mobile
				data[:mobile_phone] = pn
			else
				puts "don't recognise number: #{phone_number} (interpreted as: #{pn})"
			end
		end

		conf.keys.reject { |k| [:unknown_phone].include? k || /^_/ === k }.each do |k|
			if row[conf[k]].is_a? Array
				data[k] = row.values_at(*conf[k]).compact.first
			else
				data[k] = row[conf[k]] if row[conf[k]]
			end
		end

		if data[:first_name]
			data[:first_name].gsub!(/NEW\s+\d+\/\d+/, ' ')
			data[:first_name].gsub!(/\(.*\)/, '')
			data[:first_name].strip!
		end

		if data[:last_name]
			data[:last_name].gsub!(/\(.*\)/, '')
			data[:last_name].gsub!(/\s+/, ' ')
			data[:last_name].gsub!(/NEW\s+\d+\/\d+/, ' ')
			data[:last_name].strip!
		end

		if conf[:_group_type]
			data[:group_type_state_uuid] = Reference::Data::State::GroupType.first!(name: conf[:_group_type].upcase).state_uuid
		elsif /&/ === row["Status"] || /&/ === row["Greeting"]
			data[:group_type_state_uuid] = Reference::Data::State::GroupType.first!(name: "HOUSEHOLD").state_uuid
			data[:contact_name] = row["Greeting"]
			data[:group_name] = row.values_at("Status", "First Name", "Last Name").compact.map(&:strip).reject(&:blank?).join(" ")
			data[:prefix] = data[:first_name] = data[:middle_name] = data[:last_name] = nil
		end

		if row["Comments"] and email = row["Comments"].split(/\s+/).find { |l| /^[a-z0-9_.+\-]+@[a-z0-9\-]+\.[a-z0-9\-.]+$/i === l }
			data[:email] = email
		end

		if data[:id].present?
			data[:id_check] = Suku::Supporters::Data::SupporterValidations.aluhn_checksum(data[:id])
		end

		# if conf[:dedupe]
		duplicate_search_params = data.each_with_object({}) do |(k, v), o|
			case k
			when :first_name, :middle_name, :last_name
				o["normalized_#{k}".to_sym] = v
			else
				o[k] = v if Suku::Duplicates::VALID_KEYS.include? k
			end
		end

		if duplicate_search_params.values_at(:normalized_first_name, :normalized_last_name, :normalized_middle_name).any?
			supporter_state_uuid = Suku::Duplicates.supporters_for_attributes_with_datetime(
				duplicate_search_params,
				interaction.datetime
			)

			if supporter_state_uuid
				puts "Successfully deduped someone"
				return Supporters::Data::State::Supporter[supporter_state_uuid]
			end
		end

		supporter = Supporters::Data::State::Supporter.new data
		supporter.save or raise "#{supporter.to_hash} caused: #{supporter.errors}"
		supporter
	end

	def note(row, conf, interaction, supporter)
		return if row[conf[:value]].blank?
		note = Supporters::Data::History::Note.new(
			supporter: supporter,
			interaction: interaction,
			value: row[conf[:value]].strip
		)
		note.save or raise supporter.errors.to_s
		note
	end

	def group_membership(row, conf, interaction, supporter)
		group = Supporters::Data::State::Supporter.where(
			group_name: row[conf[:group_name]].strip,
			group_type: Reference::Data::State::GroupType.where(name: conf[:group_type_name]),
		).first

		return if group.nil?

		gm = Supporters::Data::State::GroupMember.new(
			interaction: interaction,
			group: group,
			member: supporter,
		)
		gm.valid?
		gm.save or raise "GroupMember failed to save: #{gm.errors}"
		gm
	end

	def address(row, conf, interaction, supporter)
		data = {interaction: interaction, supporter: supporter}
		data[:type] = Reference::Data::State::Type.first!(name: 'HOME', table_name: 'supporter_state.addresses')

		conf.each do |dst, src|
			data[dst] = row[src] if row[src]
		end

		if data[:country]
			data[:country].gsub!(/\s*\d+/, '')

			{
				'Ausralia'        => 'AUS',
				'Central America' => 'Guatemala',
				'ENGLAND'         => 'UNITED KINGDOM',
				'FIJI ISLANDS'    => 'FIJI',
				'KAZAKSTAN'       => 'KAZAKHSTAN',
				'N. IRELAND'      => 'GBR',
				'SOUTH KOREA'     => 'KOR',
				'Taiwan, ROC'     => 'TWN',
				'WALES'           => 'GBR',
				/^KOREA/          => 'KOR',
			}.each do |k, v|
				if k === data[:country]
					data[:country] = v
					break
				end
			end
		end

		address = Supporters::Data::State::Address.new data

		address.save or raise address.errors.to_s
		address
	end

	def relationships(row, conf, interaction, supporter)
		# conf = {sponsor: {
		# 	first_name: 'Sponsor Given Name',
		# 	last_name: 'Sponsor Surname',
		# 	email: 'Sponsor Email',
		# }}

		relationship = Supporters::Data::State::RelationshipType.first! name: "sponsor"

		primary = [
			{
				first_name: row['Sponsor Given Name'],
				last_name: row['Sponsor Surname'],
				email: row['Sponsor Email'],
			},
			{
				group_type_state_uuid: Reference::Data::State::GroupType.first!(name: "HOUSEHOLD").state_uuid,
				group_name: row.values_at("Sponsor Given Name", "Sponsor Surname").compact.map(&:strip).reject(&:blank?).join(" "),
				email: row['Sponsor Email'],
			},
			{
				email: row['Sponsor Email'],
			},
			{
				group_type_state_uuid: Reference::Data::State::GroupType.first!(name: "HOUSEHOLD").state_uuid,
				group_name: row.values_at("Sponsor Given Name", "Sponsor Surname").compact.map(&:strip).reject(&:blank?).join(" "),
			},
		].find do |params|
			pr = Supporters::Data::State::Supporter.first params
			break pr if pr
			false
		end

		if primary.nil?
			puts "\e[31mCan't find sponsor in: #{row}\e[0m"

			primary = if /&/ === row["Sponsor Given Name"]
				Supporters::Data::State::Supporter.new(
					# email: row['Sponsor Email'],
					group_type_state_uuid: Reference::Data::State::GroupType.first!(name: "HOUSEHOLD").state_uuid,
					group_name: row.values_at("Sponsor Given Name", "Sponsor Surname").compact.map(&:strip).reject(&:blank?).join(" "),
				)
			else
				Supporters::Data::State::Supporter.new(
					# email: row['Sponsor Email'],
					first_name: row["Sponsor Given Name"],
					last_name: row["Sponsor Surname"],
				)
			end
			primary.email = row['Sponsor Email'] if /^[a-z0-9_.+\-]+@[a-z0-9\-]+\.[a-z0-9\-.]+$/i === row['Sponsor Email']
			primary.interaction = interaction
			primary.save or raise "Can't save new sponsor: #{primary.errors}"
		else
			puts "\e[32mFOUND SPONSOR!\e[0m"
		end

		datetime = [interaction.datetime, supporter.history.first.from_date, primary.history.first.from_date].max

		interaction = Interactions::Data::History::Interaction.new(
			datetime: datetime,
			type: 'CLI',
			source: 'EMPLOYEE',
			target: 'SYSTEM',
			description: 'Initial data import',
			audit_user_identifier: 'aidan.samuel@supporterhub.com'
		).save or raise interaction.errors.to_s

		relationship = Supporters::Data::State::Relationship.new(
			interaction: interaction,
			primary: primary,
			secondary: supporter,
			relationship_type: relationship,
		)

		relationship.save or raise relationship.errors.to_s
		relationship
	end

	def ensure_type(type_name)
		normalised_type_name = type_name.to_s.gsub(/_/, ' ').strip.upcase
		@type_lk[normalised_type_name] ||= Reference::Data::State::Type.find_or_create(
			table_name: 'reference_state.flag_names',
			name: normalised_type_name,
		) do |type|
			puts "Creating type: #{normalised_type_name}"
			type.interaction = origin_interaction
		end
	end

	def ensure_flag(fn, category_name)
		normalised_flag_name = fn.to_s.gsub(/_/, ' ').strip.upcase
		@flag_name_lk[[normalised_flag_name, category_name]] ||= Reference::Data::State::FlagName.find_or_create(
			name: normalised_flag_name,
			type: ensure_type(category_name)
		) do |flag_name|
			puts "Creating flag_name: #{normalised_flag_name} (category: #{category_name})"
			flag_name.interaction = origin_interaction
		end
	end

	def flags(row, conf, interaction, supporter)

		conf.each do |category, flag_conf|
			category_name = category.to_s.capitalize

			flag_conf.each do |flag_name, value|
				next unless row[value]

				row[value].split(/[,;]/).map(&:strip).select { |x| x.length > 0 }.uniq.each do |fn|
					flag = case flag_name
					when :_
						ensure_flag(fn, category_name)
					when /_\w+/
						ensure_flag(flag_name, category_name)
					else
						ensure_flag(flag_name, category_name)
					end

					flag = Supporters::Data::State::SupporterFlag.new(
						interaction: interaction,
						supporter: supporter,
						flag_name: flag,
					)
					flag.save or (
						raise "#{flag.to_hash} caused #{flag.errors}" unless flag.errors == {:name=>["duplicate"]}
					)
					flag
				end
			end
		end
	end

	def origin_interaction
		@oi ||= Interactions::Data::History::Interaction.order_by(:datetime).first!
	end

	def get_data(fn)
		path = Pathname.new(@base_dir) + fn
		raise "Missing file #{fn}" unless path.exist?

		headers, *data = CSV.foreach(path).to_a
		headers.map! { |h| h.nil? ? '' : h.strip }

		data.map do |row|
			headers.zip(row).to_h
		end
	end

	def analyse_data(rows)
		row_count = rows.count

		headers = rows.first.keys # will break on empty file

		headers.each do |key|
			puts "Column \e[33m#{key}\e[0m"
			rows.map { |x| x[key] }.each_with_object(Hash.new(0)) do |v, o|
				o[v] += 1
			end.reject { |k, _| k.nil? }.sort_by { |k, v| v }.reverse.first(5).each { |k, v|
				puts "%5d (%3.1f%%): \e[32m%s\e[0m" % [v, ((v * 100.0) / row_count), k]
			}
			puts ""
		end
		puts ""
	end

	def analyse_all_files
		@files.each do |fn, _|
			analyse_file fn
		end
		true
	end

	def analyse_file(fn)
		rows = get_data fn
		puts "Processing \e[31m#{fn}\e[0m \e[36m(#{rows.count} rows)\e[0m"
		analyse_data rows
	end

	def import_all
		start = Time.now
		@files.each do |fn, conf|
			if conf[:import]
				print "\e[41mProcessing #{fn}\n\e[0m"
			else
				print "\e[41mSkipping #{fn}\n\e[0m"
				next
			end

			if conf[:preprocessor]
				send conf[:preprocessor], get_data(fn)
			end


			get_data(fn).each_with_index do |row, i|

				puts "\e[32;1m#{fn}:#{i}\e[0m"

				if conf[:drop_if].any? { |k, v| v.is_a?(Array) ? v.include?(row[k]) : (v === row[k].try(:strip)) }
					puts "Dropping row #{i}"
					next
				end

				interaction = nil
				supporter = nil

				conf[:mappings].each do |key, mapping|
					resp = send key, row, mapping, interaction, supporter
					interaction = resp if key == :interaction
					supporter = resp if key == :supporter
				end

			rescue => e
				puts "\e[1m#{fn}:#{i} \e[101m#{e.class}: #{e.message}\e[0m"
				# binding.pry
				# _pry_.hooks.errors.first.backtrace
			end
		end
		puts "Elapsed time: %i seconds" % [Time.now - start]
		true
	end

end;

# DMImport.new.analyse_all_files

# DB.transaction(rollback: :always) do
	DMImport.new.import_all
	puts "Imported: #{Supporters::Data::State::Supporter.count}"
# end