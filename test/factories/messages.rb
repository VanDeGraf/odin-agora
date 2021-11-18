FactoryBot.define do
  factory :message do
    body { Faker::Lorem.paragraph(sentence_count: 2, random_sentences_to_add: 10) }
  end
end
