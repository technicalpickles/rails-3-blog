require "cases/helper"
require 'models/topic'
require 'models/reply'

class I18nValidationTest < ActiveRecord::TestCase
  def setup
    Topic.reset_callbacks(:validate)
    @topic = Topic.new
    @old_load_path, @old_backend = I18n.load_path, I18n.backend
    I18n.load_path.clear
    I18n.backend = I18n::Backend::Simple.new
    I18n.backend.store_translations('en', :activerecord => {:errors => {:messages => {:custom => nil}}})
  end

  def teardown
    Topic.reset_callbacks(:validate)
    I18n.load_path.replace @old_load_path
    I18n.backend = @old_backend
  end

  def unique_topic
    @unique ||= Topic.create :title => 'unique!'
  end

  def replied_topic
    @replied_topic ||= begin
      topic = Topic.create(:title => "topic")
      topic.replies << Reply.new
      topic
    end
  end

  # ActiveRecord::Errors
  def test_errors_generate_message_translates_custom_model_attribute_key
    I18n.expects(:translate).with(
      :topic,
      { :count => 1,
        :default => ['Topic'],
        :scope => [:activerecord, :models]
      }
    ).returns('Topic')

    I18n.expects(:translate).with(
      :"topic.title",
      { :count => 1,
        :default => ['Title'],
        :scope => [:activerecord, :attributes]
      }
    ).returns('Title')

    I18n.expects(:translate).with(
      :"models.topic.attributes.title.invalid",
      :value => nil,
      :scope => [:activerecord, :errors],
      :default => [
        :"models.topic.invalid",
        'default from class def error 1',
        :"messages.invalid"],
      :attribute => "Title",
      :model => "Topic"
    ).returns('default from class def error 1')

    @topic.errors.generate_message :title, :invalid, :default => 'default from class def error 1'
  end

  def test_errors_generate_message_translates_custom_model_attribute_keys_with_sti

    I18n.expects(:translate).with(
      :reply,
      { :count => 1,
        :default => [:topic, 'Reply'],
        :scope => [:activerecord, :models]
      }
    ).returns('Reply')

    I18n.expects(:translate).with(
      :"reply.title",
      { :count => 1,
        :default => [:'topic.title', 'Title'],
        :scope => [:activerecord, :attributes]
      }
    ).returns('Title')

    I18n.expects(:translate).with(
      :"models.reply.attributes.title.invalid",
      :value => nil,
      :scope => [:activerecord, :errors],
      :default => [
        :"models.reply.invalid",
        :"models.topic.attributes.title.invalid",
        :"models.topic.invalid",
        'default from class def',
        :"messages.invalid"],
      :model => 'Reply',
      :attribute => 'Title'
    ).returns("default from class def")

    Reply.new.errors.generate_message :title, :invalid, :default => 'default from class def'

  end

  # validates_uniqueness_of w/ mocha

  def test_validates_uniqueness_of_generates_message
    Topic.validates_uniqueness_of :title
    @topic.title = unique_topic.title
    @topic.errors.expects(:generate_message).with(:title, :taken, {:default => nil, :value => 'unique!'})
    @topic.valid?
  end

  def test_validates_uniqueness_of_generates_message_with_custom_default_message
    Topic.validates_uniqueness_of :title, :message => 'custom'
    @topic.title = unique_topic.title
    @topic.errors.expects(:generate_message).with(:title, :taken, {:default => 'custom', :value => 'unique!'})
    @topic.valid?
  end

  # validates_associated w/ mocha

  def test_validates_associated_generates_message
    Topic.validates_associated :replies
    replied_topic.errors.expects(:generate_message).with(:replies, :invalid, {:value => replied_topic.replies, :default => nil})
    replied_topic.valid?
  end

  def test_validates_associated_generates_message_with_custom_default_message
    Topic.validates_associated :replies
    replied_topic.errors.expects(:generate_message).with(:replies, :invalid, {:value => replied_topic.replies, :default => nil})
    replied_topic.valid?
  end

  # validates_associated w/o mocha

  def test_validates_associated_finds_custom_model_key_translation
    I18n.backend.store_translations 'en', :activerecord => {:errors => {:models => {:topic => {:attributes => {:replies => {:invalid => 'custom message'}}}}}}
    I18n.backend.store_translations 'en', :activerecord => {:errors => {:messages => {:invalid => 'global message'}}}

    Topic.validates_associated :replies
    replied_topic.valid?
    assert_equal ['custom message'], replied_topic.errors[:replies]
  end

  def test_validates_associated_finds_global_default_translation
    I18n.backend.store_translations 'en', :activerecord => {:errors => {:messages => {:invalid => 'global message'}}}

    Topic.validates_associated :replies
    replied_topic.valid?
    assert_equal ['global message'], replied_topic.errors[:replies]
  end

end
