require 'rails_helper'

RSpec.describe ForgotPasswordAttempt, type: :model do
  it { should validate_presence_of(:user_id) }

  it { should belong_to(:user) }
end
