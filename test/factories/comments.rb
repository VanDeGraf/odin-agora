FactoryBot.define do
  factory :comment do
    body { Faker::Lorem.paragraph(sentence_count: 2, random_sentences_to_add: 10) }

    factory :comment_with_author do
      association :author, factory: :user
    end
  end
end
