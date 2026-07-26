class HealthController < ApplicationController
  def show
    render plain: "200 OK", status: :ok
  end
end
