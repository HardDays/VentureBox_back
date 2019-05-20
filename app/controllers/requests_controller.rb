class RequestsController < ApplicationController
  swagger_controller :requests, "Request info"

  # POST /requests
  swagger_api :create do
    summary "Request info"
    param :form, :name, :string, :required, "Requestor name"
    param :form, :email, :string, :required, "Requestor website"
    param :form, :requested_name, :string, :optional, "Requested company info"
    param_list :form, :interested_in, :string, :optional, "What requestor interested in", [:investing, :advisor, :purchasing]
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
      params.permit(:name, :email, :requested_name, :interested_in)
    end
end
