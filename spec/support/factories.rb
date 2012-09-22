FactoryGirl.define do
  factory :style do
    sequence(:name){|n| "style#{n}"}
    content <<-LESS
body { 
  color: @variable1;
}
LESS
  end

  factory :variable do
    sequence(:name){|n| "variable#{n}"}
    sequence(:label){|n| "Variable #{n}"}
    type :color
  end

  factory :package do
    sequence(:name){|n| "package#{n}"}
    sequence(:label){|n| "Package #{n}"}
    type "less"
    styles{ [FactoryGirl.build(:style)] }
    variables{ [FactoryGirl.build(:variable)] }
  end
end