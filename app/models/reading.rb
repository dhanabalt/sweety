class Reading < ActiveRecord::Base

	DAILY_READING_COUNT_LIMIT = 4

	scope :today_readings, -> {where("created_at >=?", Time.zone.now.beginning_of_day)}
	scope :month_to_date_readings, -> (begin_date,end_date) {where(:created_at => begin_date.beginning_of_day..end_date.end_of_day)}

	validates :glucose_level, presence: true
	validate :validate_reading

	REPORT_TYPE = {"1" => "daily_report","2" => "month_to_date_report","3" => "monthly_report"}

	def self.reached_today_count
		today_readings.count >= DAILY_READING_COUNT_LIMIT
	end

	def validate_reading
	end

	def self.report(user,params)
		self.send (REPORT_TYPE[params["type"]]).to_sym, user.readings, params
	end

	def self.daily_report(readings,params={})
		report_to_hash(readings.today_readings,"Daily Report")
	end

	def self.month_to_date_report(readings,params={})
		reading_date = params["reading"]
		end_date = date_conversion_from_date_select(reading_date)
		begin_date = end_date.beginning_of_month
		report_to_hash(readings.month_to_date_readings(begin_date,end_date),"Month To Date Report")
	end

	def self.monthly_report(readings,params={})
		reading_date = params["reading"]
		begin_date = date_conversion_from_date_select(reading_date)
		end_date = begin_date.end_of_month
		report_to_hash(readings.month_to_date_readings(begin_date,end_date),"Monthly Report")
	end

	def self.report_to_hash(readings,title)
		{minimum: readings.minimum(:glucose_level),maximum: readings.maximum(:glucose_level),average: readings.average(:glucose_level),title: title}
	end

	def self.date_conversion_from_date_select(reading_date)
		Date.new(reading_date["created_at(1i)"].to_i,reading_date["created_at(2i)"].to_i,reading_date["created_at(3i)"].to_i)
	end


end
