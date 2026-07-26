class UploadsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]
  before_action :authenticate_with_token_or_session!, only: [:create]
  before_action :authenticate_user!, except: [:show, :create]
  before_action :set_upload, only: [:show, :destroy, :rename]
  before_action :check_owner, only: [:destroy, :rename]

  rescue_from ActiveRecord::RecordNotFound, with: :upload_not_found

  def index
    @uploads = current_user.uploads.order(created_at: :desc)
  end

  def show
    @upload.increment!(:views) if !current_user || @upload.user != current_user

    # Always redirect to the image blob, even for HTML requests
    redirect_to rails_blob_path(@upload.file, disposition: "inline"), allow_other_host: true
  end

  def create
    @upload = @api_user.uploads.build

    if params[:file]
      @upload.file.attach(params[:file])
      if @upload.save
        render json: {
          url: upload_url(@upload),
          direct_url: rails_blob_url(@upload.file),
          slug: @upload.slug
        }, status: :created
      else
        render json: { errors: @upload.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: "No file provided" }, status: :bad_request
    end
  end

  def rename
    if @upload.update(name: params[:name])
      redirect_to dashboard_index_path, notice: "File renamed successfully."
    else
      redirect_to dashboard_index_path, alert: "Failed to rename file."
    end
  end

  def destroy
    @upload.destroy
    redirect_to dashboard_index_path, notice: "File deleted successfully."
  end

  private

  def upload_not_found
    if request.format.html?
      render plain: "404 Not Found - This file does not exist or has been deleted.", status: :not_found
    else
      render json: { error: "File not found" }, status: :not_found
    end
  end

  def set_upload
    # If the user tries to access /uploads/SLUG.jpg, Rails interprets params[:id] as "SLUG" and params[:format] as "jpg"
    # Or sometimes they add extensions manually. We should be robust:
    clean_id = params[:id].to_s.split('.').first
    @upload = Upload.find_by!(slug: clean_id)
  end

  def check_owner
    unless @upload.user == current_user || current_user.admin?
      redirect_to root_path, alert: "You don't have permission to do that."
    end
  end

  def authenticate_with_token_or_session!
    auth_header = request.headers['Authorization'] || params[:token]

    if auth_header.present?
      token = auth_header.to_s.sub('Bearer ', '')
      @api_user = User.find_by(token: token)

      unless @api_user
        render json: { error: 'Invalid API token' }, status: :unauthorized
      end
    elsif user_signed_in?
      @api_user = current_user
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end
end
