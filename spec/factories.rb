FactoryBot.define do
  factory :feed do
    uri { "http://example.com/feed" }
    name { "Example Feed" }
    user { "test_user" }
  end

  factory :feed_item do
    association :feed
    title { "Test Feed Item" }
    link { "http://example.com/item" }
    timestamp { Time.current.utc }
    description { "A description" }
    key { "some_unique_key" }
  end
end