class Weather < ApplicationRecord
    before_save :normalize_city_state

    private
    def normalize_city_state
        binding.pry
        self.city = city.downcase if city.present?
        self.state = state.downcase if state.present?
    end
end
