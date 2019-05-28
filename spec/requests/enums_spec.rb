require 'rails_helper'

RSpec.describe "Enums", type: :request do

  # Test suite for GET /enums/c_level
  describe 'GET /enums/c_level' do
    context 'when simply get' do
      before do
        get "/enums/c_level"
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end
  end

  # Test suite for GET /enums/stage_of_funding
  describe 'GET /enums/stage_of_funding' do
    context 'when simply get' do
      before do
        get "/enums/stage_of_funding"
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end
  end

  # Test suite for GET /enums/tags
  describe 'GET /enums/tags' do
    context 'when simply get' do
      before do
        get "/enums/tags"
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end
  end
end
