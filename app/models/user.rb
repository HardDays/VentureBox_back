class User < ApplicationRecord
  validates_presence_of :name
  validates_presence_of :surname
  validates :email, presence: true, uniqueness: true

  validates :password, presence:true, length: {:within => 6..100}, :allow_blank => false
  before_save :encrypt, if: :password_changed?
  validates_confirmation_of :password, message: 'NOT_MATCHED'
  attr_accessor :password_confirmation

  validate :check_old, if: :password_changed?, on: :update
  attr_accessor :old_password

  enum role: [:startup, :investor]

  has_many :tokens, dependent: :destroy
  has_many :forgot_password_attempts, dependent: :destroy
  has_one :company, dependent: :destroy

  SALT = ENV.fetch("PASSWORD_SALT")

  def self.encrypt_password(password)
    return Digest::SHA256.hexdigest(password + SALT)
  end

  def encrypt
    self.password = User.encrypt_password(self.password) if self.password
  end

  def check_old
    if self.old_password != nil
      errors.add(:old_password, 'NOT_MACHED') if User.find(id).password != User.encrypt_password(self.old_password)
    else
      errors.add(:old_password, 'MUST_EXIST')
    end
  end

  def as_json(options={})
    res = super(options)

    res.delete('password')
    res
  end
end
