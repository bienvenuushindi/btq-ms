# frozen_string_literal: true
module CountryService
  module Helper
    def self.country_params(params)
      params.require(:country).permit(:name, :code)
    end
  end

end
