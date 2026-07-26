class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :uploads, dependent: :destroy

  before_create :generate_token

  private

  def generate_token
    self.token = SecureRandom.hex(8)
  end
end
