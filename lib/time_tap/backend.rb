require 'active_support/core_ext/string/inflections'

module TimeTap::Backend
  def self.load backend, options = {}
    require "time_tap/backend/#{backend}"
    klass = const_get(backend.to_s.classify)
    klass.new options
  end
end
