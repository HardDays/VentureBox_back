class ForgotPasswordAttempt < ApplicationRecord
  validates_presence_of :user_id
  validates_inclusion_of :attempts_count, in: 1..3

  belongs_to :user
end
