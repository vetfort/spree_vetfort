module SpreeVetfort
  VERSION = '0.0.4'.freeze

  module_function

  # Returns the version of the currently loaded SpreeVetfort as a
  # <tt>Gem::Version</tt>.
  def version
    Gem::Version.new VERSION
  end
end
