module SpreeVetfort
  VERSION = '0.6.7'.freeze

  module_function

  # Returns the version of the currently loaded SpreeVetfort as a
  # <tt>Gem::Version</tt>.
  def version
    Gem::Version.new VERSION
  end
end
