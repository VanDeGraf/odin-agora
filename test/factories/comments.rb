FactoryBot.define do
  factory :comment do
    body { Faker::Lorem.paragraph(sentence_count: 2, random_sentences_to_add: 10) }

    factory :comment_with_author do
      association :author, factory: :user
    end
    factory :comment_with_post do
      association :post, factory: :post_with_author

      factory :comment_with_post_and_author do
        association :author, factory: :user
      end
    end
  end
end
