# frozen_string_literal: true
module ProductService
  module Options
    def self.search
      { fields: { product: %i[name details] } }
    end
  end
end
