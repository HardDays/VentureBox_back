class Token < ApplicationRecord
  validates_presence_of :user_id
  validates_presence_of :token

  belongs_to :user
end
