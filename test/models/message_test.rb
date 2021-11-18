require "test_helper"

class MessageTest < ActiveSupport::TestCase
  test 'valid' do
    message = FactoryBot.build(:message_with_sender_and_recipient)
    assert message.valid?, message.errors.full_messages
  end
  test 'can save' do
    message = FactoryBot.build(:message_with_sender_and_recipient)
    message.save
    assert_not_nil(message.id, message.errors.full_messages)
  end
  test 'sender association' do
    user = FactoryBot.create(:user)
    message = FactoryBot.create(:message_with_recipient, sender_id: user.id)
    assert_kind_of(User, message.sender)
    assert_equal(message.sender.id, user.id)
  end
  test 'recipient association' do
    user = FactoryBot.create(:user)
    message = FactoryBot.create(:message_with_sender, recipient_id: user.id)
    assert_kind_of(User, message.recipient)
    assert_equal(message.recipient.id, user.id)
  end
end
