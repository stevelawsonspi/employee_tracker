require 'csv'
load 'duplicates/supporters_for_attributes.rb'
load 'duplicates/supporters_for_attributes_with_datetime.rb'

class AAAImport

	THREADS = 0

	FLAGS = {
		'CONTACT TYPE' => {
			'AAA GENERAL'            => :drop,
			'ACCOUNT'                => :keep,
			'CLASSICAL MUSIC'        => :drop,
			'DONOR'                  => :keep,
			'EDUCATION'              => 'EDUCATOR',
			'EDUCATOR'               => :keep,
			'FAMILY MEMBER / FRIEND' => :keep,
			'FUNDRAISER'             => :keep,
			'GENERAL'                => :drop,
			'GOVERNMENT'             => :keep,
			'INDIVIDUAL WITH ASD'    => :keep,
			'INDUSTRY CONTACT'       => :keep,
			'MEDIA'                  => :keep,
			'OTHER'                  => :keep,
			'PARENT / CARER'         => :keep,
			'PARTNER'                => 'PARTNER / SPONSOR',
			'RESEARCHER'             => :keep,
			'SERVICE PROVIDER'       => :keep,
			'VOLUNTEER'              => :keep,
			'POTENTIAL SPONSOR'      => :new,
			'SPEAKER'                => :new,
			'SDF'                    => :drop,
			'DSFSD'                  => :drop,
			'AAAA'                   => :drop,
			'KK'                     => :drop,
		},
		'DONOR' => {
			'CITY2SURF 2015'                                                          => 'DONOR',
			'COAST 2 COAST II CHARITY CHALLENGE 2014'                                 => 'DONOR',
			'DIRECT DONATION'                                                         => 'DONOR',
			'DNOR FOR CITY2SURF 2012'                                                 => 'DONOR',
			'DONOR FOR AUSTRALIAN RUNNING FESTIVAL 2012'                              => 'DONOR',
			'DONOR FOR CANBERRA TIMES AUSTRALIAN RUNNING FESTIVAL 2013'               => 'DONOR',
			'DONOR FOR CANBERRA TIMES AUSTRALIAN RUNNING FESTIVAL 2014'               => 'DONOR',
			'DONOR FOR CANBERRA TIMES AUSTRALIAN RUNNING FESTIVAL 2015'               => 'DONOR',
			'DONOR FOR CANBERRA TIMES FUN RUN 2012'                                   => 'DONOR',
			'DONOR FOR CANBERRA TIMES FUN RUN 2013'                                   => 'DONOR',
			'DONOR FOR CHANNEL TEN 1 MILLION KILO CHALLENGE'                          => 'DONOR',
			'DONOR FOR CITY2SURF 2011'                                                => 'DONOR',
			'DONOR FOR CITY2SURF 2012'                                                => 'DONOR',
			'DONOR FOR CITY2SURF 2013'                                                => 'DONOR',
			'DONOR FOR CITY2SURF 2014'                                                => 'DONOR',
			'DONOR FOR CITY2SURF 2015'                                                => 'DONOR',
			'DONOR FOR CITY2SURF 2016'                                                => 'DONOR',
			'DONOR FOR COAST 2 COAST II CHARITY CHALLENGE 2014'                       => 'DONOR',
			'DONOR FOR COMMUNITY GIVING'                                              => 'DONOR',
			'DONOR FOR GOLD COAST AIRPORT MARATHON 2016'                              => 'DONOR',
			'DONOR FOR KELLER AUSTRALIA COAST 2 COAST CHARITY CHALLENGE III'          => 'DONOR',
			'DONOR FOR KNIGHT FRANK POINT TO PINNACLE 2014'                           => 'DONOR',
			'DONOR FOR LIGHT IT UP BLUE 2013'                                         => 'DONOR',
			'DONOR FOR LIGHT IT UP BLUE 2014'                                         => 'DONOR',
			'DONOR FOR NOT SPECIFIED'                                                 => 'DONOR',
			'DONOR FOR RESOLUTION RUN 2011'                                           => 'DONOR',
			'DONOR FOR RUN MELBOURNE 2011'                                            => 'DONOR',
			'DONOR FOR RUN MELBOURNE 2012'                                            => 'DONOR',
			'DONOR FOR RUN MELBOURNE 2013'                                            => 'DONOR',
			'DONOR FOR RUN MELBOURNE 2014'                                            => 'DONOR',
			'DONOR FOR RUN MELBOURNE 2015'                                            => 'DONOR',
			'DONOR FOR RUN MELBOURNE 2016'                                            => 'DONOR',
			'DONOR FOR RUN4FUN 2012'                                                  => 'DONOR',
			'DONOR FOR SUNCORP COMMUNITY GIVING 2016'                                 => 'DONOR',
			'DONOR FOR SUNDAY MAIL CITY-BAY FUN RUN 2011'                             => 'DONOR',
			'DONOR FOR SUNDAY MAIL CITY-BAY FUN RUN 2012'                             => 'DONOR',
			'DONOR FOR SURFERS HEALING AUSTRALIA'                                     => 'DONOR',
			'DONOR FOR SYDNEY MORNING HERALD COLE CLASSIC AND SUN RUN 2011'           => 'DONOR',
			'DONOR FOR SYDNEY MORNING HERALD HALF MARATHON 2016'                      => 'DONOR',
			'DONOR FOR THE 2011 REBEL SPORT RUN4FUN PRESENTED BY THE SUN-HERALD'      => 'DONOR',
			'DONOR FOR THE 2016 SYDNEY MORNING HERALD SUN RUN & COLE CLASSIC'         => 'DONOR',
			'DONOR FOR THE CANBERRA TIMES CANBERRA MARATHON'                          => 'DONOR',
			'DONOR FOR THE SUNDAY AGE CITY2SEA 2011'                                  => 'DONOR',
			'DONOR FOR THE SUNDAY AGE CITY2SEA 2012'                                  => 'DONOR',
			'DONOR FOR THE SUNDAY AGE CITY2SEA 2013'                                  => 'DONOR',
			'DONOR FOR THE SUNDAY AGE CITY2SEA 2014'                                  => 'DONOR',
			'DONOR FOR THE SUNDAY MAIL SUNCORP BANK BRIDGE TO BRISBANE 2014'          => 'DONOR',
			'DONOR FOR THE SUNDAY MAIL SUNCORP BANK BRIDGE TO BRISBANE 2015'          => 'DONOR',
			'DONOR FOR THE SYDNEY MORNING HERALD'                                     => 'DONOR',
			'DONOR FOR THE SYDNEY MORNING HERALD HALF MARATHON 2011'                  => 'DONOR',
			'FUNDRAISER AND DONOR FOR OWN CAMPAIGN'                                   => 'FUNDRAISER',
			'FUNDRAISER FOR CANBERRA TIMES AUSTRALIAN RUNNING FESTIVAL 2013'          => 'FUNDRAISER',
			'FUNDRAISER FOR CANBERRA TIMES AUSTRALIAN RUNNING FESTIVAL 2014'          => 'FUNDRAISER',
			'FUNDRAISER FOR CANBERRA TIMES AUSTRALIAN RUNNING FESTIVAL 2015'          => 'FUNDRAISER',
			'FUNDRAISER FOR CANBERRA TIMES FUN RUN 2012'                              => 'FUNDRAISER',
			'FUNDRAISER FOR CANBERRA TIMES FUN RUN 2013'                              => 'FUNDRAISER',
			'FUNDRAISER FOR CHANNEL TEN 1 MILLION KILO CHALLENGE'                     => 'FUNDRAISER',
			'FUNDRAISER FOR CITY2SURF 201'                                            => 'FUNDRAISER',
			'FUNDRAISER FOR CITY2SURF 2011'                                           => 'FUNDRAISER',
			'FUNDRAISER FOR CITY2SURF 2012'                                           => 'FUNDRAISER',
			'FUNDRAISER FOR CITY2SURF 2013'                                           => 'FUNDRAISER',
			'FUNDRAISER FOR CITY2SURF 2014'                                           => 'FUNDRAISER',
			'FUNDRAISER FOR CITY2SURF 2015'                                           => 'FUNDRAISER',
			'FUNDRAISER FOR CITY2SURF 2016'                                           => 'FUNDRAISER',
			'FUNDRAISER FOR COMMUNITY GIVING'                                         => 'FUNDRAISER',
			'FUNDRAISER FOR GOLD COAST AIRPORT MARATHON 2016'                         => 'FUNDRAISER',
			'FUNDRAISER FOR KNIGHT FRANK POINT TO PINNACLE 2014'                      => 'FUNDRAISER',
			'FUNDRAISER FOR LIGHT IT UP BLUE 2014'                                    => 'FUNDRAISER',
			'FUNDRAISER FOR OWN CAMPAIGN'                                             => 'FUNDRAISER',
			'FUNDRAISER FOR PADDLE4AUTISM'                                            => 'FUNDRAISER',
			'FUNDRAISER FOR RUN MELBOURNE 2011'                                       => 'FUNDRAISER',
			'FUNDRAISER FOR RUN MELBOURNE 2012'                                       => 'FUNDRAISER',
			'FUNDRAISER FOR RUN MELBOURNE 2013'                                       => 'FUNDRAISER',
			'FUNDRAISER FOR RUN MELBOURNE 2014'                                       => 'FUNDRAISER',
			'FUNDRAISER FOR RUN MELBOURNE 2015'                                       => 'FUNDRAISER',
			'FUNDRAISER FOR RUN MELBOURNE 2016'                                       => 'FUNDRAISER',
			'FUNDRAISER FOR SUNDAY MAIL CITY-BAY FUN RUN 2011'                        => 'FUNDRAISER',
			'FUNDRAISER FOR SUNDAY MAIL CITY-BAY FUN RUN 2012'                        => 'FUNDRAISER',
			'FUNDRAISER FOR SYDNEY MORNING HERALD COLE CLASSIC AND SUN RUN 2011'      => 'FUNDRAISER',
			'FUNDRAISER FOR SYDNEY MORNING HERALD COLE CLASSIC AND SUN RUN 2013'      => 'FUNDRAISER',
			'FUNDRAISER FOR THE 2011 REBEL SPORT RUN4FUN PRESENTED BY THE SUN-HERALD' => 'FUNDRAISER',
			'FUNDRAISER FOR THE 2016 SYDNEY MORNING HERALD HALF MARATHON'             => 'FUNDRAISER',
			'FUNDRAISER FOR THE 2016 SYDNEY MORNING HERALD SUN RUN & COLE CLASSIC'    => 'FUNDRAISER',
			'FUNDRAISER FOR THE CANBERRA TIMES CANBERRA MARATHON'                     => 'FUNDRAISER',
			'FUNDRAISER FOR THE CANBERRA TIMES FUN RUN PRESENTED BY WESTPAC 2016'     => 'FUNDRAISER',
			'FUNDRAISER FOR THE SUNDAY AGE CITY2SEA 2011'                             => 'FUNDRAISER',
			'FUNDRAISER FOR THE SUNDAY AGE CITY2SEA 2012'                             => 'FUNDRAISER',
			'FUNDRAISER FOR THE SUNDAY AGE CITY2SEA 2013'                             => 'FUNDRAISER',
			'FUNDRAISER FOR THE SUNDAY AGE CITY2SEA 2014'                             => 'FUNDRAISER',
			'FUNDRAISER FOR THE SUNDAY MAIL CITY-BAY FUN RUN 2010'                    => 'FUNDRAISER',
			'FUNDRAISER FOR THE SUNDAY MAIL SUNCOR'                                   => 'FUNDRAISER',
			'FUNDRAISER FOR THE SUNDAY MAIL SUNCORP BANK BRIDGE TO BRISBANE 2014'     => 'FUNDRAISER',
			'FUNDRAISER FOR THE SUNDAY MAIL SUNCORP BANK BRIDGE TO BRISBANE 2015'     => 'FUNDRAISER',
			'FUNDRAISER FOR THE SUNDAY MAIL SUNCORP BANK BRIDGE TO BRISBANE 2016'     => 'FUNDRAISER',
			'FUNDRAISER FOR THE SYDNEY MORNING HERALD HALF MARATHON 2011'             => 'FUNDRAISER',
			'FUNDRAISER FOR WEIGH IT UP'                                              => 'FUNDRAISER',
			'TEST' => :drop,
			'TEST RECORD' => :drop,
			'TESTING' => :drop,
		},
		'EVENT ATTENDANCE' => {
			'AMBASSADORSFORAUTISM'    => :keep,
			'AUSTISM 2018'            => :keep,
			'BPO  2015'               => 'BPO - 2015',
			'BPO - 2015'              => :keep,
			'BPO - TEACHERS 2015'     => :keep,
			'BPO 2013'                => :keep,
			'DAD FILM'                => 'DAD FILM 2018',
			'JOHN ELDER ROBISON 2016' => :keep,
			'SHA 2015 MANLY'          => :keep,
			'SHA 2015 NOOSA'          => :keep,
			'SHA 2016 MANLY'          => :keep,
			'SHA 2016 PERTH'          => :keep,
			'SHA 2017 BONDI'          => :keep,
			'SHA 2018'                => :keep,
		},
		'PURCHASES' => {
			'OTHER'                   => :keep,
			'WAYD DVD PURCHASE'       => :keep,
		},
		'PREFERENCE' => {
			'DO NOT EMAIL'            => :keep,
		},
		'ATTRIBUTES' => {
			'LEAD'                    => :keep,
		}
	}

	FILE = {
		'Zoho Accounts.csv' => {
			import: true,
			dedupe: false,
			mappings: {
				interaction: {
					datetime: "Created_Time",
					parser: '%Y-%m-%d %H:%M:%S+%Z'
				},
				supporter: {
					email: 'Email',
					group_name: 'Account_Name',
					unknown_phone: 'Phone',
					_group_type: 'Organisation',
				},
				external_id: {
					id: "Id",
					_external_id_type: "Zoho",
				},
				address: {
					line_1: 'Street',
					city: 'Suburb',
					state: 'State',
					postcode: 'Post_Code',
					_type: 'HOME',
					# country: 'Country', # it's always Australia
				},
				flags: {
					contact_type: {
						account: true
					}
				},
				# relationships: {},
			},
		},
		'Zoho contacts.csv' => {
			import: true,
			dedupe: true,
			mappings: {
				interaction: {
					datetime: "Created_Time",
					parser: '%Y-%m-%d %H:%M:%S+%Z'
				},
				supporter: {
					prefix: ['Saultation', 'Title'],
					email: 'Email',
					first_name: 'First_Name',
					last_name: 'Last_Name',
					unknown_phone: ['Phone', 'Mobile'],
				},
				external_id: {
					id: "Id",
					_external_id_type: "Zoho",
				},
				note: {
					body: 'Description',
				},
				group_membership: {
					parent_external_id: 'Account_Name'
				},
				address: {
					line_1: 'Street',
					city: 'Suburb',
					state: 'State',
					postcode: 'Post_Code',
					country: 'Country',
					_type: 'HOME',
				},
				flags: {
					preference: {
						do_not_email: 'Email_Opt_Out',
					},
					contact_type: {
						_: 'Contact_Type',
					},
					event_attendance: {
						_: 'Autism_Awareness_Events',
					},
					donor: {
						_: 'Fundraising_Campaign',
					},
					purchases: {
						_: 'Purchases'
					},
				},
			},
		},
		'Zoho leads.csv' => {
			import: false,
			dedupe: true,
			mappings: {
				interaction: {
					datetime: "Created_Time",
					parser: '%Y-%m-%d %H:%M:%S+%Z'
				},
				supporter: {
					prefix: ['Saultation', 'Title'],
					email: 'Email',
					first_name: 'First_Name',
					last_name: 'Last_Name',
					unknown_phone: ['Phone', 'Mobile'],
				},
				external_id: {
					id: "Id",
					_external_id_type: "Zoho",
				},
				note: {
					body: 'Description',
				},
				group_membership: {
					parent_external_id: 'Account_Name'
				},
				address: {
					line_1: 'Street',
					city: 'Suburb',
					state: 'State',
					postcode: 'Post_Code',
					country: 'Country',
					_type: 'HOME',
				},
				flags: {
					preference: {
						do_not_email: 'Email_Opt_Out',
					},
					attributes: {
						lead: true,
					}
				},
			},
		},
		'MAILCHIMP AAA Main Subscribed contacts.csv' => {
			import: false,
			dedupe: true,
			mappings: {
				interaction: {
					datetime: "Created_Time",
					parser: '%Y-%m-%d %H:%M:%S+%Z'
				},
				supporter: {},
				address: {},
				flags: {},
				relationships: {},
			},
		},
		'MAILCHIMP AAA Service provider subscribed contacts.csv' => {
			import: false,
			dedupe: true,
			mappings: {
				interaction: {
					datetime: "Created_Time",
					parser: '%Y-%m-%d %H:%M:%S+%Z'
				},
				supporter: {},
				address: {},
				flags: {},
				relationships: {},
			},
		},
	}
end

# ----------------------------------


class AAAImport

	def initialize
		@base_dir = "/home/aidan/Desktop/aaa_data"
		@base_dir = "/tmp"
		@type_lk = {}
		@flag_name_lk = {}
		@files = FILE
		@flag_name_mutex = Mutex.new
		@flag_type_mutex = Mutex.new

		@default_tz = 'Australia/Sydney'
		@assume_nsw = true
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
			description: 'Data import, December 2019',
			audit_user_identifier: 'stephenl@supporterhub.com',
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
				puts "Successfully deduped someone"
				return Supporters::Data::State::Supporter[supporter_state_uuid]
			end
		end

		supporter = Supporters::Data::State::Supporter.new data
		supporter.save or raise "#{supporter.to_hash} caused: #{supporter.errors}"
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
				elsif /Other/ === row[src]
					nil
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
						interaction: interaction,
						supporter: supporter,
						flag_name: ensure_flag(flag_name.to_s, category),
					)
					supporter_flag.save or (
						raise "#{supporter_flag.to_hash} caused #{supporter_flag.errors}" unless supporter_flag.errors == {:name=>["duplicate"]}
					)
					supporter_flag
					next
				end

				next unless row[value]

				row[value].split(/[,;]/).map(&:strip).select { |x| x.length > 0 }.uniq.each do |fn|
					flag = case flag_name
					when :_
						ensure_flag(fn, category)
					when /^_\w+/
						puts "Shouldn't be here?"
						binding.pry
						ensure_flag(flag_name, category)
					else
						if /^(false|0|no|)$/i === fn
							nil
						elsif /^(true|1|yes)$/i === fn
							ensure_flag(flag_name, category)
						else
							puts "Can't determine flag presence"
							binding.pry
						end
					end

					next if flag.nil?


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

			Parallel.each(get_data(fn).each_with_index, in_threads: THREADS) do |row, i|
				interaction = nil
				supporter = nil

				conf[:mappings].each do |key, mapping|
					resp = send key, row, mapping, interaction, supporter
					interaction = resp if key == :interaction
					supporter = resp if key == :supporter
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

# AAAImport.new.analyse_all_files
AAAImport.new.import_all
