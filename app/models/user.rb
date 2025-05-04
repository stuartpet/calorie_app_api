class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :auth_token, uniqueness: true, allow_nil: true

  validates :age, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :height, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :weight, presence: true, numericality: { only_integer: true, greater_than: 0 }

  validates :gender, presence: true, inclusion: { in: %w[male female other] }
  validates :activity_level, presence: true, inclusion: { in: %w[sedentary light moderate active] }
  validates :goal, presence: true, inclusion: { in: %w[lose maintain gain] }
end
