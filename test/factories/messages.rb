FactoryBot.define do
  factory :message do
    body { Faker::Lorem.paragraph(sentence_count: 2, random_sentences_to_add: 10) }

    factory :message_with_sender do
      association :sender, factory: :user
    end
    factory :message_with_recipient do
      association :recipient, factory: :user

      factory :message_with_sender_and_recipient do
        association :sender, factory: :user
      end
    end
  end
end
