# JSON::SchemaGenerator

JSON::SchemaGenerator tries to save you some time writing [json-schemas](http://json-schema.org/) based on existing data.  I know that there are multiple valid json-schemas that could be generated for any given sample, so I won't generate the exact schema you want.  Our goal is just to make reasonable assumptions that get you close, so you can generate the basic structure and then customize your schema, rather than writing hundreds of lines by hand.

There are [many json-schema validators], but only a few generators.  The best generator I've found is a closed-source web app so you can't embed it.  I couldn't find anything to embed within an open-source Ruby project ([Pacto](https://github.com/thoughtworks/pacto)), so I hacked one together quickly.

My quick, yak-shaving implementaiton wasn't designed for maintainability, but I wrote a test suite that gives me the confidence to rewrite or even port to other languages.  The tests are in [json-schema-kata](https://github.com/maxlinc/json-schema-kata).  I called it a kata for a reason:

> Code Kata is an attempt to bring this element of practice to software development. A kata is an exercise in karate where you repeat a form many, many times, making little improvements in each. The intent behind code kata is similar.
>
> Dave Thomas [Code Kata](http://codekata.pragprog.com/2007/01/code_kata_backg.html)

## Installation

Add this line to your application's Gemfile:

    gem 'json-schema-generator'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install json-schema-generator

## Usage

Command line:
```sh
# Usage: json-schema-generator --help
# Simple example:
$ json-schema-generator my_sample.json --schema-version draft3
```

Ruby:
```ruby
file = 'my_sample.json' # or any identifier for the description
JSON::SchemaGenerator.generate file, File.read(file), {:schema_version => 'draft3'}
```

## Features

JSON::SchemaGenerate has the following features or assumptions for generating "best-guess" schemas:

* **Schema Versions**: Support draft3 and draft4 of json-schema.
* **Options**:
  * **Defaults**: Can generate default values.
  * **Descriptions**: Can generate a description indicating where the schema came from.
* **Features/Assumptions**:
  * **Detecting optional properties:** if you are using arrays (even arrays with complex nested types), the generator will use all available data to figure detect if a field is optional.
  * **Assume required:** in all other cases, I assume everything I find in the sample is required.  I believe it is better to generate a schema that is too strict than too lenient.  It is easy to review and fix false negatives, by updating the schema to mark those items as optional.  A false positive will go unnoticed and will not point you towards a solution.
  * **Detect types:** I detect objects, arrays, strings, integers, numbers and booleans.

## Known issues

* Currently assumes the root element is a hash.  Generation will fail for data that has an array as the root.

## Tests

This was a [yak shaving](http://en.wiktionary.org/wiki/yak_shaving) project.  I needed to generate schemas for a ruby project.  I wanted to embed a schema generator within a larger open-source project ([Pacto](https://github.com/thoughtworks/pacto)), and couldn't find one I could use.  So I wrote one.

There are [many json-schema validators], but only a few generators.  The best generator I've found is a closed-source Web app so you can't embed it.  I'm hoping more people will write generators in more languages.  I also hope someone replaces my quick "yak-shaving" implementation
There are many json-schema validators available in many different programming languages.  However, there are only a few generators.  I hacked this together quickly because I wanted one I could easily use in Ruby.  My implementaiton is yak-shaving, not a well-design and maintainable solution.  So I wanted acceptance tests that are fully decoupled from the implementation - even the programming language - so I can completely re-write my solution or port it to other languages.

The tests are in the json-schema-kata project.  The test runner is ruby, but it makes no assumptions about the implementation language.  Feel free to use my tests to port to any language.

## Contributing

Contributions Welcome!  It's easy to contribute tests to the json-schema-kata project.  You just need to add a sample and what you think the generated schema should look like for each supported json-schema version (draft3, draft4, etc).

Rewrites, ports, tutorials: I called the tests a "kata" because it is a small problem that is good for practicing programming skills, but could be solved many different ways.  Can you implement a generator using functional programming?  An internal DSL?  JSONPath?  Seven languages in seven Weeks?  Try it out, hone your skills, and share your results.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
