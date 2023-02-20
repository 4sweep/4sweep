class StaticPagesController < ApplicationController
  before_action :require_user, :flag_counts

  def suggestions
  end

  def faq
  end

  def contact
  end

  def changelog
  end

  def about
  end
end
