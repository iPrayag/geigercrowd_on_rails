class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable
  attr_accessible :email, :password, :password_confirmation, :remember_me,
    :real_name, :screen_name
  has_many :locations
  has_many :instruments, :as => :origin
  has_many :samples, through: :instruments
  validates_uniqueness_of :screen_name, case_sensitive: false
  validates_format_of :screen_name, with: /\A[-a-z0-9]+\Z/i, on: :create,
    message: "must only contain letters, numbers and dashes"
  after_create :create_token
  before_validation :check_for_blank_password
  validate :screen_name_is_for_ever

  def create_token
    self.reset_authentication_token!
  end

  def timezone=(tz)
    tz &&= case tz
           when ActiveSupport::TimeZone then tz.name
           when String then ActiveSupport::TimeZone.new(tz).try(:name)
           end
    write_attribute :timezone, tz
  end

  def timezone
    tz = read_attribute :timezone
    tz.present? ? ActiveSupport::TimeZone.new(tz) : nil
  end

  def to_param
    screen_name
  end

  def screen_name_matches? screen_name_in_question
    screen_name.casecmp(screen_name_in_question) == 0
  end

  def owns? instrument_or_sample
    admin? || instrument_or_sample.user = self
  end

  def self.find_by_screen_name screen_name
    first conditions: "lower(screen_name) = '#{screen_name.downcase}'"
  end

  private

  def check_for_blank_password
    if password.blank? && password_confirmation.blank?
      self.password = self.password_confirmation = nil
    end
  end

  def screen_name_is_for_ever
    if screen_name_changed? && !screen_name_was.nil?
      errors[:screen_name] << "can't be changed"
    end
  end
end
