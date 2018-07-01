class StatsController < ApplicationController
  before_filter :require_user, :except => :category_changes

  def stats

    user_id = params[:user_id] || nil

    if (!@current_user.is_admin?)
      @foruser = @current_user
      obj = @current_user.flags
    else
      if (user_id)
        @foruser = User.find(user_id)
        obj = @foruser.flags
      else
        obj = Flag
      end
    end

    if params[:date]
      datefilter = "date(flags.created_at) = ?"
    else
      datefilter = true #no op
    end

    @user_counts = obj.select("users.name, users.level, users.hometown, user_id, count(*) as flag_count").joins(:user).group('user_id').order('flag_count desc').where(datefilter, params[:date])
    @type_counts = obj.select("type, count(*) as flag_count").group("type").order("flag_count desc").where(datefilter, params[:date])
    @problem_counts = obj.select("problem, count(*) as flag_count").group("problem").order("flag_count desc").where("problem is not null").where(datefilter, params[:date])
    @status_counts = obj.select("status, count(*) as flag_count").group("status").order("flag_count desc").where(datefilter, params[:date])
    @day_counts = obj.select("date(created_at) as date, count(*) as flag_count").group("date(created_at)").order("date desc").where(datefilter, params[:date])

  end

  def category_changes
    current_user # provide current user if available
    cats = CategoriesCache.order("last_verified desc")

    @diffs = []
    for i in 0...(cats.size - 1)
      @diffs << {
        :removed => cats[i+1].aslist - cats[i].aslist,
        :added => cats[i].aslist - cats[i+1].aslist,
        :created_at => cats[i].created_at,
        :last_verified => cats[i].last_verified
      }
    end
  end
end
