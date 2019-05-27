class User < ApplicationRecord
  validates_presence_of :name
  validates_presence_of :surname

  validates :email, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, unless: Proc.new { |a| a.email.blank? }
  validate :check_current_email, if: :email_changed?, on: :update
  attr_accessor :current_email
  validate :check_email_password_confirmation, if: :email_changed?, on: :update
  attr_accessor :current_password

  validates :password, presence:true
  validates :password, length: {:within => 6..100}, unless: Proc.new { |a| a.password.blank? }
  before_save :encrypt, if: :password_changed?
  validates_confirmation_of :password, message: 'NOT_MATCHED'
  validates_presence_of :password_confirmation, message: 'MUST_EXIST', if: :password_changed?
  attr_accessor :password_confirmation

  validate :check_old, if: :password_changed?, on: :update
  attr_accessor :old_password

  validates_presence_of :role
  enum role: [:startup, :investor]

  has_one :company, dependent: :destroy
  has_many :tokens, dependent: :destroy
  has_many :forgot_password_attempts, dependent: :destroy
  has_many :invested_companies, foreign_key: :investor_id, dependent: :destroy

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

  def check_current_email
    if self.current_email != nil
      errors.add(:current_email, 'NOT_MACHED') if User.find(id).email != self.current_email
    else
      errors.add(:current_email, 'MUST_EXIST')
    end
  end

  def check_email_password_confirmation
    if self.current_password != nil
      errors.add(:current_password, 'NOT_MACHED') if User.find(id).password != User.encrypt_password(self.current_password)
    else
      errors.add(:current_password, 'MUST_EXIST')
    end
  end

  def as_json(options={})
    res = super(options)

    res.delete('password')
    res
  end
end
