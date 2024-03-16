class Api::V1::TagsController < ApplicationController
  before_action -> { find_record(Tag) },only: %i[show]

  def index
    render json: serialize_resources(Tag.all, serializer), status: :ok
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
    render_collection(paginated, serializer, options)
  end

  def create
    @tag = Tag.new(tag_params)
    if @tag.save
      render json: serialize_resource(@tag, serializer), status: :created
    else
      render json: error_response(@tag)
    end
  end

  def show
    render json: serialize_resource(@tag, serializer), status: :ok
  end

  private

  def serializer
    TagSerializer
  end


  def tag_params
    params.require(:tag).permit(:name)
  end
end
