class EnumsController < ApplicationController
  swagger_controller :enum, "Enums"

  # GET /enums/c_level
  swagger_api :c_level do
    summary "C levels enum"
    response :ok
  end
  def c_level
    render json: EnumsHelper.c_level_readable_json, status: :ok
  end

  # GET /enums/stage_of_funding
  swagger_api :stage_of_funding do
    summary "Stage of funding enum"
    response :ok
  end
  def stage_of_funding
    render json: EnumsHelper.stage_of_funding_readable_json, status: :ok
  end

  # GET /enums/tags
  swagger_api :tags do
    summary "Company item tags enum"
    response :ok
  end
  def tags
    render json: EnumsHelper.company_item_tag_readable_json, status: :ok
  end

  # GET /enums/countries
  swagger_api :countries do
    summary "Countries enum"
    response :ok
  end
  def countries
    render json: Country.all, only: [:id, :name], status: :ok
  end
end
