module Helpers
  def self.get_env(key)
    #Automatically try to be case insensitive
    return ENV[key] || ENV[key.downcase] || ENV[key.upcase]
  end
end