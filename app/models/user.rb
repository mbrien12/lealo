class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:facebook]
  has_many :skills, foreign_key: :teacher_id
  has_many :lessons, foreign_key: :student_id
  has_many :reviews, foreign_key: :student_id
  has_many :messages, foreign_key: :sender_id
  has_many :messages, foreign_key: :receiver_id
  validates :role, inclusion: { in: ["teacher", "student"] }
  validates :email, :first_name, :last_name, presence: true
  after_create :set_picture_if_nil
  mount_uploader :photo, PhotoUploader


  def self.find_for_facebook_oauth(auth, role)
    user_params = auth.slice(:provider, :uid)
    user_params.merge! auth.info.slice(:email, :first_name, :last_name)
    user_params[:facebook_picture_url] = auth.info.image
    user_params[:token] = auth.credentials.token
    user_params[:token_expiry] = Time.at(auth.credentials.expires_at)
    user_params = user_params.to_h

    user = User.find_by(provider: auth.provider, uid: auth.uid)
    user ||= User.find_by(email: auth.info.email) # User did a regular sign up in the past.
    if user
      user.update(user_params)
    else
      user = User.new(user_params)
      user.password = Devise.friendly_token[0,20]  # Fake password for validation
      user.role = role
      user.save
    end

    return user
  end

  def name
    "#{self.first_name.capitalize} #{self.last_name.capitalize}"
  end

  def set_picture_if_nil
    self.update_columns(photo: "image/upload/v1512662884/dcp0w9sxsmr9uu6ohtpk.png")
  end
end
