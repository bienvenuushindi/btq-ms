# frozen_string_literal: true
module BaseService
  class Updater < ApplicationService
    include UtilitiesHelper

    def initialize(resource, params)
      @resource = resource
      @params = params
    end

    def call
      update_resource
    end

    protected

    def update_resource
      @resource.transaction do
        update_attributes
        save_resource
      end
    end

    private

    def update_attributes
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end

    def save_resource
      @resource.save!
    end
  end
end