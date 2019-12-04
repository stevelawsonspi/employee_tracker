require 'csv'
load 'duplicates/supporters_for_attributes.rb'
load 'duplicates/supporters_for_attributes_with_datetime.rb'


class AJFNImport

	FLAGS = nil

	FILE = {
		'ajfn_guest_list.csv' => {
			import: true,
			dedupe: true,
			mappings: {
				interaction: {
					datetime: :early_interaction,
				},
				supporter: { # SLSLSL Add note with charidy amount?
					email:         'Email',
					first_name:    'First Name',
					last_name:     'Last Name',
					unknown_phone: ['Phone'],
				},
				address: {
					line_1:   'Billing Address Line 1',
					line_2:   'Billing Address Line 2',       # SLSLSL Line 2 ok?
					city:     'Billing Address City',
					state:    'Billing Address State / Area',
					postcode: 'Billing Address Zip / Postal Code',
					_type:    'HOME',
					country:  'Billing Address Country',
				},
				flags: {
					events: {
						:'charidy donor' => true,
					},
				},
			},
		},
	}
end

# ----------------------------------

class AJFNImport

	def initialize
		@base_dir = "/home/aidan/Desktop/ajfn_data"
		@base_dir = "/tmp"
		@type_lk = {}
		@flag_name_lk = {}
		@files = FILE
		@flag_name_mutex = Mutex.new
		@flag_type_mutex = Mutex.new
		@project_mutex = Mutex.new

		@assume_nsw = true
		@default_tz = 'Australia/Sydney'
	end

	def interaction(row, conf, _, _)
		datetime = if conf[:datetime] == :early_interaction
			'2019-10-30 00:00:00 +0000'
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
			description: 'event data import',
			audit_user_identifier: 'aidan.samuel@supporterhub.com',
		).save or raise interaction.errors.to_s
		interaction
	end

	def external_id(row, conf, interaction, supporter)
		puts "external_id not implemented"
	end

	def supporter(row, conf, interaction, _)
		data = {interaction: interaction}

		row.values_at(*conf[:unknown_phone]).select { |x| /\d/ === x }.each do |phone_number|
			pn = phone_number.gsub(/^['MHW]:? */, '')
			npn = pn.gsub /[^\+\d]/, ''
			pn = "0#{pn}" if /^4\d{8}/ === npn
			pn = "+#{pn}" if /^61\d{9}/ === npn
			pn = "02#{pn}" if /^[98]\d{7}/ === npn and @assume_nsw

			case Supporters::ValidatePhoneNumber.new(pn).type
			when :landline
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

		[:first_name, :last_name, :group_name, :contact_name].each do |field|
			next unless data[field]
			data[field] = data[field].gsub(/[^-\p{L} '&\.]/, ' ').strip
		end

		if conf[:_group_type]
			data[:group_type_state_uuid] = Reference::Data::State::GroupType.first!(name: conf[:_group_type].upcase).state_uuid
		end

		unless /^[a-z0-9_.+\-]+@[a-z0-9\-]+\.[a-z0-9\-.]+$/i === data[:email]
			data.delete :email
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

		if duplicate_search_params.keys.any?
			supporter_state_uuid = Suku::Duplicates.supporters_for_attributes_with_datetime(
				duplicate_search_params,
				interaction.datetime
			)

			if supporter_state_uuid
				supp = Supporters::Data::State::Supporter[supporter_state_uuid]
				puts "Successfully deduped someone: #{supp.pretty_name}"
				return supp
			end
		end

		supporter = Supporters::Data::State::Supporter.new data
		supporter.save or raise "#{supporter.to_hash} caused: #{supporter.errors}"
		puts "Created #{supporter.pretty_name}"
		supporter
	end

	def note(row, conf, interaction, supporter)
	end

	def group_membership(row, conf, interaction, supporter)
	end

	def address(row, conf, interaction, supporter)
		data = {interaction: interaction, supporter: supporter}
		data[:type] = Reference::Data::State::Type.first!(name: 'HOME', table_name: 'supporter_state.addresses')

		conf.each do |dst, src|
			next unless row[src]
			if dst == :country
				data[dst] = if /United States/ === row[src]
					'USA'
				else
					row[src]
				end
			else
				data[dst] = row[src]
			end

		end

		address = Supporters::Data::State::Address.new data
		address.save or raise "#{address.to_hash} caused #{address.errors}"
		address
	end

	def ensure_type(type_name)
		normalised_type_name = type_name.to_s.gsub(/_/, ' ').strip.upcase
		@flag_type_mutex.synchronize do
			@type_lk[normalised_type_name] ||= Reference::Data::State::Type.find_or_create(
				table_name: 'reference_state.flag_names',
				name: normalised_type_name,
			) do |type|
				puts "Creating type: #{normalised_type_name}"
				type.interaction = origin_interaction
			end
		end
	end

	def ensure_flag(fn, category)

		category_name = category.to_s.strip.gsub(/_/, ' ').upcase
		normalised_flag_name = fn.to_s.gsub(/_/, ' ').strip.upcase

		if Hash === FLAGS
			mapping = FLAGS.dig(category_name, normalised_flag_name)
			raise "no flag mapping found for (#{normalised_flag_name}:#{category_name})" if mapping.nil?

			normalised_flag_name = case mapping
			when :keep
				normalised_flag_name
			when :drop
				return nil
			when String
				mapping
			else
				raise "Unexpected flag definition"
			end
		end

		category_name = "EMAIL LISTS" if normalised_flag_name == "NORTH CINEMA FOR THE SOUL 2019"

		@flag_name_mutex.synchronize do
			@flag_name_lk[[normalised_flag_name, category_name]] ||= Reference::Data::State::FlagName.find_or_create(
				name: normalised_flag_name,
				type: ensure_type(category_name)
			) do |flag_name|
				puts "Creating flag_name: #{normalised_flag_name} (category: #{category_name})"
				flag_name.interaction = origin_interaction
			end
		end
	end

	def flags(row, conf, interaction, supporter)

		conf.each do |category, flag_conf|

			flag_conf.each do |flag_name, value|

				if value === true
					flag = ensure_flag(flag_name.to_s, category)
					if flag.nil?
						puts "Can't find flag for #{category}:#{flag_name}"
						return nil
					end

					supporter_flag = Supporters::Data::State::SupporterFlag.new(
						interaction: interaction.create_effect,
						supporter: supporter,       # SLSLSL is "supporter" just saving the supporter.id? 
						flag_name: ensure_flag(flag_name.to_s, category),
					)
					supporter_flag.save or (
						raise "#{supporter_flag.to_hash} caused #{supporter_flag.errors}" unless supporter_flag.errors == {:name=>["duplicate"]}
					)
					supporter_flag
					next
				end

				next unless row[value]  # SLSLSL ?

				row[value].split(/[,;]/).map(&:strip).select { |x| x.length > 0 }.uniq.each do |fn|
					flag = case flag_name
					when :_
						ensure_flag(fn, category)
					when /_\w+/
						ensure_flag(flag_name, category)
					else
						ensure_flag(flag_name, category)
					end

					if flag.nil?
						puts "Dropping flag: #{flag_name.to_s} or #{fn}:[#{category}]"
						next
					end

					supporter_flag = Supporters::Data::State::SupporterFlag.new(
						interaction: interaction,
						supporter: supporter,
						flag_name: flag,
					)
					supporter_flag.save or (
						raise "#{supporter_flag.to_hash} caused #{supporter_flag.errors}" unless supporter_flag.errors == {:name=>["duplicate"]}
					)
					supporter_flag
				end
			end
		end
	end

	def early_interaction
		@early_interaction ||= Interactions::Data::History::Interaction.order_by(:datetime).first  # SLSLSL Why grab early interaction?
	end

	def early_project
		@project_mutex.synchronize do
			@early_project ||= Projects::Data::State::Project.find_or_create(
				name: "Initial data import",
				description: "",
			) do |x|
				x.type = Reference::Data::State::Type.first!(name: 'FUNDRAISING', table_name: 'project_state.projects')
				x.interaction = early_interaction
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
			next unless conf[:import]

			get_data(fn).each_with_index do |row, i|
				interaction = nil  #SLSLSL Why a new interaction for each record?
				supporter = nil

				conf[:mappings].each do |key, mapping|
					resp        = send key, row, mapping, interaction, supporter
					interaction = resp if key == :interaction
					supporter   = resp if key == :supporter
				end

			rescue => e
				puts "\e[1m#{fn}:#{i} \e[101m#{e.class}: #{e.message}\e[0m"
				binding.pry
			end
		end
		puts "Elapsed time: %i seconds" % [Time.now - start]
		true
	end

end;

# AJFNImport.new.analyse_all_files
DB.transaction() do
	AJFNImport.new.import_all
end
