FactoryBot.define do
  factory :friendship do
    invite { false }

    factory :friendship_with_friend do
      association :friend, factory: :user
    end
    factory :friendship_with_other_friend do
      association :other_friend, factory: :user

      factory :friendship_with_friends do
        association :friend, factory: :user
      end
    end
  end
end
