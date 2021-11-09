puts 'Generate db seed...'
require 'faker'

Faker::Config.random = Random.new(1)
@creation_date_stub = DateTime.current.prev_day
password = '123456'
puts "\tCreate users..."
user_ids = []
ActiveRecord::Base.transaction do
  user_ids = 100.times.map do
    User.create(
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      sex: Faker::Number.between(from: 0, to: 2),
      birthday: Faker::Date.birthday(min_age: 18, max_age: 65),
      avatar_url: Faker::Avatar.image,
      email: Faker::Internet.safe_email,
      password: password,
      password_confirmation: password,
      confirmed_at: @creation_date_stub
    ).id
  end
end

puts "\tCreate friendship between users..."
# @param invite [Boolean]
# @param inviter_id [Integer]
# @param requester_id [Integer]
def add_friendship(invite, inviter_id, requester_id)
  invite = invite ? 'true' : 'false'
  sql = <<~SQL
    INSERT INTO friends
    VALUES (#{invite}, #{inviter_id}, #{requester_id}, "#{@creation_date_stub}", "#{@creation_date_stub}")
  SQL
  ActiveRecord::Base.connection.exec_query(sql)
end

ActiveRecord::Base.transaction do
  (1..10).each { |i| add_friendship(false, user_ids[0], user_ids[i]) }
  (11..20).each { |i| add_friendship(false, user_ids[i], user_ids[0]) }
  (21..30).each { |i| add_friendship(true, user_ids[0], user_ids[i]) }
  (31..40).each { |i| add_friendship(true, user_ids[i], user_ids[0]) }

  (2..10).each { |i| add_friendship(false, user_ids[1], user_ids[i]) }
  (11..20).each { |i| add_friendship(false, user_ids[i], user_ids[1]) }
  (21..30).each { |i| add_friendship(true, user_ids[1], user_ids[i]) }
  (31..40).each { |i| add_friendship(true, user_ids[i], user_ids[1]) }
end

puts "\tCreate posts..."
post_ids = []
ActiveRecord::Base.transaction do
  post_ids = 100.times.map do
    Post.create(
      author_id: user_ids[Faker::Number.between(from: 0, to: 20)],
      title: Faker::Lorem.sentence(word_count: 2, random_words_to_add: 2),
      body: Faker::Lorem.paragraph(sentence_count: 4, random_sentences_to_add: 10)
    ).id
  end
end

puts "\tCreate post likes..."

def set_like(user_id, post_id)
  sql = <<~SQL
    INSERT INTO likes
    VALUES (#{user_id}, #{post_id})
  SQL
  ActiveRecord::Base.connection.exec_query(sql)
end

ActiveRecord::Base.transaction do
  post_ids.each do |post_id|
    user_ids.reverse.first(20).each do |user_id|
      next if Faker::Boolean.boolean

      set_like(user_id, post_id)
    end
  end
end

puts "\tCreate comments..."
comment_ids = []
ActiveRecord::Base.transaction do
  comment_ids = 500.times.map do
    Comment.create(
      author_id: user_ids[Faker::Number.between(from: 0, to: 20)],
      post_id: post_ids[Faker::Number.between(from: 0, to: post_ids.length - 1)],
      body: Faker::Lorem.paragraph(sentence_count: 2, random_sentences_to_add: 5)
    ).id
  end
end

puts "\tCreate messages..."
message_ids = []
ActiveRecord::Base.transaction do
  message_ids = 100.times.map do
    sender_id = user_ids[Faker::Number.between(from: 1, to: 20)]
    recipient_id = user_ids[0]
    if Faker::Boolean.boolean
      sender_id, recipient_id = recipient_id, sender_id
    end
    Message.create(
      sender_id: sender_id,
      recipient_id: recipient_id,
      body: Faker::Lorem.paragraph(sentence_count: 2, random_sentences_to_add: 5)
    ).id
  end
end

puts "Successfully generate db seed."
puts "You can login with example user: email:#{User.find(user_ids[0]).email}, password:#{password}"