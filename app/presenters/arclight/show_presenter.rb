# frozen_string_literal: true

module Arclight
  # Custom presentation methods for show partial
  class ShowPresenter < Blacklight::ShowPresenter
    def heading
      title = super
      date = document.fetch('unitdate_ssm', [])
      title += ", #{date.first}" if date.present?
      title
    end
  end
end
