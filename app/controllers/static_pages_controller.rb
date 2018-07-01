class StaticPagesController < ApplicationController
  before_filter :require_user, :flag_counts

  def suggestions
  end

  def faq
  end

  def contact
  end

  def changelog
  end
end
