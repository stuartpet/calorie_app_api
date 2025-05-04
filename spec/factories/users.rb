FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'password' }
    age { 25 }
    height { 175 }
    weight { 70 }
    gender { 'male' }
    activity_level { 'moderate' }
    goal { 'maintain' }
    auth_token { SecureRandom.hex(20) }
  end
end