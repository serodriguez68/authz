class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :reports

  include OpinionatedPundit::Authorizable
  register_in_authorization_admin identifier: :name

  def name
    "#{id} - #{email}"
  end

end
