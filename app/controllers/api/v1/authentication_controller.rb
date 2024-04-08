class Api::V1::AuthenticationController < ApplicationController
    def check_auth
        render json: { data: {authenticated: true} }, status: :ok
    end
end
  
