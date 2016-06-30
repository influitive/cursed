

# Cursed [![CircleCI](https://circleci.com/gh/influitive/cursed.svg?style=svg)](https://circleci.com/gh/influitive/cursed)

Cursed is a gem that implements the cursoring pattern in Postgres with the
ActiveRecord and Sequel gems.  The cursoring pattern is an alternative to
traditional pagination which is superior in that it is stable for collections
that are constantly changing.

Instead of providing a parameter `page` we instead provide any of three
parameters `before`, `after` and `limit` (you may customize these as you wish).
By choosing to 'paginate' by providing the maximum ID you know about you can
be assured that the same record will not appear twice if records behind it have
changed it's position.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cursed'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cursed

## Usage

In your controller code call your collection in this manner.

```ruby
Cursed::Collection.new(
  relation: MyModel.unscoped,
  cursor: Cursed::Cursor.new(
    after: params[:after],
    before: params[:before],
    limit: params[:limit],
    maximum: 20
  )
)
```

The `Collection` is enumerable so you can use it as you would us any array

```erb
<% @collection.each do |record| %>
  <%= record.name %>
<% end %>
```

To generate your next link and previous link merge in the values of `#next_page_params`
and `#prev_page_params` into your URL generator

```erb
  <%= link_to 'Previous Page', widgets_path(collection.prev_page_params) %>
  <%= link_to 'Next Page', widgets_path(collection.next_page_params) %>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/influitive/cursed.

## License

This gem is licensed under the MIT license.
