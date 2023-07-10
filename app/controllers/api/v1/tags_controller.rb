class Api::V1::TagsController < ApplicationController
  before_action :set_tag, only: %i[show]

  def index
    render json: fetch_response(Tag.all), status: :ok
  end

  def create
    tag = Tag.new(tag_params)
    if tag.save
      render json: created_response(tag), status: :created
    else
      render json: error_response(tag)
    end
  end

  def show
    render json: fetch_response(set_tag), status: :ok
  end

  private

  def set_tag
    Tag.find(params[:id])
  end

  def tag_params
    params.require(:tag).permit(:name)
  end
end
