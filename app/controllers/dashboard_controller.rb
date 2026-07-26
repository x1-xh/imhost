class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @uploads = current_user.uploads.includes(file_attachment: :blob).order(created_at: :desc).limit(10)

    @total_uploads = current_user.uploads.count
    @total_views = current_user.uploads.sum(:views)

    # Calculate storage used
    @storage_used = current_user.uploads.joins(file_attachment: :blob).sum('active_storage_blobs.byte_size')

    # Data for the chart
    @uploads_by_day = current_user.uploads.where('created_at >= ?', 7.days.ago)
                                        .group('date(created_at)')
                                        .count
  end
end
