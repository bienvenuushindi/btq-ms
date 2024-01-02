class Api::V1::TagsController < ApplicationController
  before_action :set_tag, only: %i[show]

  def index
    render json: serializer.new(Tag.all), status: :ok
  end

  def search
    tags = nil
    options = {}
    if params[:q].present?
      options[:fields] = { tag: [:name] }
      tags = Tag.all.search(params[:q])
      tags = tags.order(created_at: :desc)
    end
    paginated = tags.present? ? paginate(tags)  : paginate(ActsAsTaggableOn::Tag.most_used(10))
    render_collection(paginated, options)
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

  def serializer
    TagSerializer
  end

  def set_tag
    Tag.find(params[:id])
  end

  def tag_params
    params.require(:tag).permit(:name)
  end
end
