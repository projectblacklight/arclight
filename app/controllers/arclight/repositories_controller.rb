# frozen_string_literal: true

module Arclight
  # Controller for our /repositories index page
  class RepositoriesController < ApplicationController
    def index
      @repositories = Arclight::Repository.all
    end
  end
end
