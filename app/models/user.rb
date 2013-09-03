class User < ActiveRecord::Base
  include Importable

  validates :name, presence: true
  validates :username, :email, presence: true, uniqueness: true

  has_secure_password
end

