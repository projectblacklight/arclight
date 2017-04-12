# Arclight

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/arclight`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'arclight'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install arclight
```

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

### Run a development server

```sh
$ bundle exec rake arclight:server
```

Then visit http://localhost:3000. It will also start a Solr instance on port 8983.

### Run the test suite

Ensure Solr and Rails are not running (ports 8983 and 3000 respectively), then:

```sh
$ bundle exec rake
```

### Release

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, build the gem file (e.g., `gem build arclight.gemspec`) and push the `.gem` file to [rubygems.org](https://rubygems.org) (e.g., `gem push arclight-x.y.z.gem`).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sul-dlss/arclight.

## License

The gem is available as open source under the terms of the [Apache 2 License](https://opensource.org/licenses/Apache-2.0).
