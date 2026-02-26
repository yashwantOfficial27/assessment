require "rails_helper"
require 'webmock/rspec'

RSpec.describe "Whereami API", type: :request do
  let(:ip) { "8.8.8.8" }
  let(:url) { "https://jsonmock.hackerrank.com/api/ip/#{ip}" }
  let(:headers) { { "X-Language" => "en" } }

  describe "GET /whereami" do

    context "when ip is missing" do
      it "returns 400" do
        get "/whereami"

        expect(response.status).to eq(400)
        expect(JSON.parse(response.body)["error"]).to eq("IP missing")
      end
    end

    context "when external API returns success" do
      before do
        stub_request(:get, url)
          .with(
            headers: {
              "Accept-Language" => "en"
            }
          )
          .to_return(
            status: 200,
            body: { data: {country: "India"} }.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "returns country and language" do
        get "/whereami", params: { ip: ip }, headers: headers

        json = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(json["ip"]).to eq(ip)
        expect(json["country"]).to eq("India")
        expect(json["language"]).to eq("en")
      end
    end

    context "when country is missing in API response" do
      before do
        stub_request(:get, url)
          .to_return(
            status: 200,
            body: {}.to_json
          )
      end

      it "returns 404" do
        get "/whereami", params: { ip: ip }, headers: headers

        expect(response.status).to eq(404)
        expect(JSON.parse(response.body)["error"]).to eq("Country not found")
      end
    end

    context "when external API fails" do
      before do
        stub_request(:get, url)
          .to_return(status: 500)
      end

      it "returns 502" do
        get "/whereami", params: { ip: ip }, headers: headers

        expect(response.status).to eq(502)
        expect(JSON.parse(response.body)["error"]).to eq("External API error")
      end
    end
  end
end