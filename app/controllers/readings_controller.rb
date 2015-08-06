class ReadingsController < ApplicationController
	before_action :authenticate_user!
	before_action :check_reading_limit, only: [:new,:create]
	before_action :set_readings
	layout "application", only: [:month_to_date_report,:monthly_report,:report] 

	def index
		@reached_reading_limit = current_user.readings.reached_today_count
	end

	def new
		@reading = Reading.new
	end

	def create
		@reading = current_user.readings.new(reading_params)
		if @reading.save
			redirect_to readings_path,notice: "Reading created successfully"
		else
			render "new"
		end
	end

	def report
		@readings = Reading.report(current_user,params)
	end


	private

	def set_readings
		@readings = current_user.readings.today_readings
	end

	def reading_params
		params.require(:reading).permit(:glucose_level)
	end

	def check_reading_limit
		if current_user.readings.reached_today_count
			redirect_to readings_path,notice: "Reached todays reading limit"
		end
	end
end
