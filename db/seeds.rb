require_relative 'seed_helper'

puts 'Generate db seed:'

DATA = {
  user: {
    id: []
  },
  post: {
    id: [],
    author_id: []
  },
}

if OPTIONS[:user][:create]
  info_stage 'Create users'
  email_generator = UniqGenerator.new(-> { Faker::Internet.safe_email })
  data = OPTIONS[:user][:count].times.map do
    {
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      sex: Faker::Number.between(from: 0, to: 2),
      birthday: Faker::Date.birthday(min_age: 18, max_age: 65),
      email: email_generator.value,
      encrypted_password: OPTIONS[:stub][:encrypted_password],
      confirmed_at: OPTIONS[:stub][:datetime],
      created_at: OPTIONS[:stub][:datetime],
      updated_at: OPTIONS[:stub][:datetime]
    }
  end
  DATA[:user] = table_inserts('users', data)
  info_stage_item "#{DATA[:user][:id].length} users created"

  if OPTIONS[:user][:create_avatar]
    users = User.find(DATA[:user][:id])
    ActiveRecord::Base.transaction do
      users.each do |user|
        user.attach_avatar_from_url(Faker::Avatar.image)
        user.save
      end
    end
    info_stage_item "avatar attached for every created user"
  end
  if OPTIONS[:user][:create_friendship]
    intersections = uniq_intersections(
      DATA[:user][:id],
      DATA[:user][:id],
      count_from: (DATA[:user][:id].length / 10).to_i
    )
    data = intersections.map do |pair|
      {
        invite: Faker::Boolean.boolean,
        friend_id: pair[0],
        other_friend_id: pair[1],
        created_at: OPTIONS[:stub][:datetime],
        updated_at: OPTIONS[:stub][:datetime]
      }
    end
    friendships = table_inserts('friends', data, 'friend_id')
    info_stage_item "#{friendships.length} friendships created"
  end
end

if OPTIONS[:post][:create]
  info_stage 'Create posts'
  create_user_if_not_exists
  data = OPTIONS[:post][:count].times.map do
    {
      title: Faker::Lorem.sentence(word_count: 2, random_words_to_add: 2),
      body: Faker::Lorem.paragraph(sentence_count: 4, random_sentences_to_add: 30),
      author_id: DATA[:user][:id][Faker::Number.between(from: 0, to: DATA[:user][:id].length - 1)],
      created_at: OPTIONS[:stub][:datetime],
      updated_at: OPTIONS[:stub][:datetime]
    }
  end
  DATA[:post] = table_inserts('posts', data, %w[id author_id])
  info_stage_item "#{DATA[:post][:id].length} posts created"
  if OPTIONS[:post][:create_likes]
    intersections = uniq_intersections(
      DATA[:post][:id],
      DATA[:user][:id],
      count_from: DATA[:post][:id].length
    )
    data = []
    intersections.each do |pair|
      next if DATA[:post][:author_id][DATA[:post][:id].find_index(pair[0])] == pair[1]
      data << {
        post_id: pair[0],
        user_id: pair[1]
      }
    end
    likes = table_inserts('likes', data, 'post_id')
    info_stage_item "#{likes.nil? ? '0' : likes.length} likes created"
  end
  if OPTIONS[:post][:comment][:create]
    data = OPTIONS[:post][:comment][:count].times.map do
      post_id = DATA[:post][:id][Faker::Number.between(from: 0, to: DATA[:post][:id].length - 1)]
      author_id =DATA[:user][:id][Faker::Number.between(from: 0, to: DATA[:user][:id].length - 1)]
      {
        author_id: author_id,
        post_id: post_id,
        body: Faker::Lorem.paragraph(sentence_count: 2, random_sentences_to_add: 10),
        created_at: OPTIONS[:stub][:datetime],
        updated_at: OPTIONS[:stub][:datetime]
      }
    end
    comments = table_inserts('comments', data)
    info_stage_item "#{comments[:id].length} comments created"
  end
end

if OPTIONS[:message][:create]
  info_stage 'Create messages'
  create_user_if_not_exists
  intersections = uniq_intersections(
    DATA[:user][:id],
    DATA[:user][:id]
  )
  data = intersections.map do |pair|
    {
      body: Faker::Lorem.paragraph(sentence_count: 2, random_sentences_to_add: 10),
      sender_id: pair[0],
      recipient_id: pair[1],
      created_at: OPTIONS[:stub][:datetime],
      updated_at: OPTIONS[:stub][:datetime]
    }
  end
  messages = table_inserts('messages', data)
  info_stage_item "#{messages.nil? ? '0' : messages[:id].length} messages created"
end

puts "Successfully generate db seed."
if !(user_id = DATA[:user][:id].first).nil? && !(user = User.find(user_id)).nil?
  puts "You can login with example user: email:#{user.email}, password:#{OPTIONS[:stub][:password]}"
end
