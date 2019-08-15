# frozen_string_literal: true

module Arclight

  ##
  # A module to add set locales that is sent to application controller
  module LocaleBehavior
    extend ActiveSupport::Concern
    included do
      before_action :set_locale

      private

      def set_locale
        I18n.locale = params[:locale] || I18n.default_locale
      end
    end
  end
end
