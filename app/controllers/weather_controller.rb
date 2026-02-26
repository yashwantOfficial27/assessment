class WeatherController < ApplicationController
    # get list of all weathers
    def list
        weather = Weather.all 
        
        weather = Weather.where(city: params[:city].downcase) if params[:city].present?
        weather = Weather.where(state: params[:state].downcase) if params[:state].present?
        weather = Weather.where(created_at: params[:date]) if params[:date].present?

        render json: {result: weather}, status: :ok
    end

    def create
        weather = Weather.new(weather_params)
        if weather.save
            render json: weather, status: :created 
        else
            render json: weather.errors, status: :unprocessable_entity
        end
    end

    def show
        weather = Weather.find_by_id(params[:id].to_i)
        if weather.present?
            render json: weather, status: :ok
        else
            render json: {error: "Record not found"}, status: :not_found
        end
    end

    private
    def weather_params
        params.require(:weather).permit(:lat, :lon, :city, :state, temperatures: [])
    end
end