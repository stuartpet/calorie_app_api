FactoryBot.define do
  factory :food_item do
    name { "MyString" }
    calories { 1 }
    protein { 1 }
    carbs { 1 }
    fat { 1 }
    sugar { 1 }
    salt { 1 }
    source { "MyString" }
  end
end
