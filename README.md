# CatarsePayroll

[Catarse](http://github.com/catarse/catarse) payment engine for corporate payroll payments

## Installation

Add this line to your Catarse application's Gemfile:

    gem 'catarse_payroll'

And then execute:

    $ bundle

## Usage

Configure the routes for your Catarse application. Add the following lines in the routes file (config/routes.rb):

    mount CatarsePayroll::Engine => "/", :as => "catarse_payroll"

## Development environment setup

Clone the repository:

    $ git clone git://github.com/danielweinmann/catarse_payroll.git

Add the Catarse code into test/dummy:

    $ git submodule add git://github.com/catarse/catarse.git test/dummy

Copy the Catarse's gems to Gemfile:

    $ cat test/dummy/Gemfile >> Gemfile

And then execute:

    $ bundle

Replace the content of test/dummy/config/boot.rb with this:

    require 'rubygems'
    gemfile = File.expand_path('../../../../Gemfile', __FILE__)
    if File.exist?(gemfile)
      ENV['BUNDLE_GEMFILE'] = gemfile
      require 'bundler'
      Bundler.setup
    end
    YAML::ENGINE.yamler= 'syck' if defined?(YAML::ENGINE)

    $:.unshift File.expand_path('../../../../lib', __FILE__)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


This project rocks and uses MIT-LICENSE.
