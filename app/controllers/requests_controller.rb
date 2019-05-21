class RequestsController < ApplicationController
  swagger_controller :requests, "Request info"

  # POST /requests
  swagger_api :create do
    summary "Request info"
    param :form, :name, :string, :required, "Requestor name"
    param :form, :email, :string, :required, "Requestor email"
    param :form, :requested_name, :string, :optional, "Requested company info"
    param :form, :interested_in_investing, :boolean, :optional, "requestor interested in"
    param :form, :interested_in_advisor, :boolean, :optional, "requestor interested in"
    param :form, :interested_in_purchasing, :boolean, :optional, "requestor interested in"
    response :created
    response :unprocessable_entity
  end
  def create
    @request = Request.new(request_params)

    if @request.save
      render json: @request, status: :created
    else
      render json: @request.errors, status: :unprocessable_entity
    end
  end

  private
    def request_params
      params.permit(:name, :email, :requested_name, :interested_in_investing, :interested_in_advisor, :interested_in_purchasing)
    end
end
