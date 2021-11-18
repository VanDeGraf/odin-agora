FactoryBot.define do
  factory :post do
    title { Faker::Lorem.sentence(word_count: 2, random_words_to_add: 2) }
    body { Faker::Lorem.paragraph(sentence_count: 4, random_sentences_to_add: 30) }

    factory :post_with_author do
      association :author, factory: :user
    end
  end
end
