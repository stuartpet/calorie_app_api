# app/serializers/user_serializer.rb
class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :age, :height, :weight, :gender, :activity_level, :goal, :auth_token, :username
end
