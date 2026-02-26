class WhereamiController < ApplicationController
    require 'net/http'
    def index
        # ip = request.remote_ip
        ip = params[:ip]
        unless ip.present?
            # return render json: {"ip": nil, "country": nil, "language": nil}, status: :bad_request 
            return render json: {"error": 'IP missing'}, status: :bad_request 
        end
        country = detect_country(ip)
        country = JSON.parse(country)

        if country.empty?
            return render json: {"error": "Country not found"}, status: :not_found 
        end

        country = country['data']['country']
        language = request.env["HTTP_X_LANGUAGE"]

        render json: {"ip": ip, "country": country, "language": language}, status: :ok
    rescue Exception => ex 
        return render json: {"error": "External API error"}, status: 502
    end

    def detect_country(ip)
        url = "https://jsonmock.hackerrank.com/api/ip/#{ip}"
        response = HTTParty.get(url,
                                headers: {
                                    "Accept-Language" => "en"
                                }                            
        )
        return response.body
    end
end