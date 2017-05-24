module RedmineOracle
  class UserPasswordMatch < ActiveRecord::Base
    class << self
      def authenticate(username, password)
        establish_connection(specs_for(username, password)).connection
        true
      rescue OCIError => ex
        return false if [1017].include?(ex.code)
        raise "#{ex}"
      end

      private

      def specs_for(username, password)
        spec = configurations['oracle']
        new_spec = spec.clone
        new_spec['username'] = username
        new_spec['password'] = password
        new_spec
      end
    end
  end
end
