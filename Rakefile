# frozen_string_literal: true
require 'bundler/gem_tasks'
task default: :spec

require "bundler/gem_tasks"

# Monkey patch Bundler gem_helper so we release to our gem server instead of rubygems.org
# http://www.alexrothenberg.com/2011/09/16/running-a-private-gemserver-inside-the-firewall.html
module Bundler
  class GemHelper
    def rubygem_push(path)
      gem_server_url = 'http://influitive-server:qua7eiH7aix0KeetIetaig2a@gems.internal.influitive.com'
      sh("gem inabox '#{path}' --host #{gem_server_url}")
      Bundler.ui.confirm "Pushed #{name} #{version} to #{gem_server_url}"
    end
  end
end
