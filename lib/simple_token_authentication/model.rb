require 'active_support/concern'
require 'simple_token_authentication/token_generator'
require 'simple_token_authentication/strategy'

module Devise
  module Models
    module SimpleTokenAuthenticatable
      extend ActiveSupport::Concern

      # Please see https://gist.github.com/josevalim/fb706b1e933ef01e4fb6
      # before editing this file, the discussion is very interesting.

      included do
        private :generate_authentication_token
        private :token_suitable?
        private :token_generator        
        before_save :ensure_authentication_token
      end

      # Set an authentication token if missing
      #
      # Because it is intended to be used as a filter,
      # this method is -and should be kept- idempotent.
      def ensure_authentication_token
        if authentication_token.blank?
          self.authentication_token = generate_authentication_token
        end
      end

      def generate_authentication_token
        loop do
          token = Devise.friendly_token
          break token if token_suitable?(token)
        end
      end
  
      def token_suitable?(token)
        self.class.where(authentication_token: token).count == 0
      end

      module ClassMethods
      end
    end
  end
end
