require 'rails_helper'

RSpec.describe User, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:surname) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }
  it { should validate_presence_of(:role) }

  it { should have_one(:company).dependent(:destroy) }
  it { should have_many(:tokens).dependent(:destroy) }
  it { should have_many(:forgot_password_attempts).dependent(:destroy) }
  it { should have_many(:invested_companies).dependent(:destroy) }
end
