# This is called when Pingdom does a health check by hitting https://4sweep.com/heartbeat, roughly every 5 min.
class HeartbeatController < ApplicationController
  def heartbeat
    submit_cloudwatch()
    render :json => {"status" => "OK"}, :status => 200
  end

  private
  def submit_cloudwatch
    now = Delayed::Job.db_time_now
    failed_jobs = Delayed::Job.where("failed_at is not null").count
    first_unprocessed = Delayed::Job.where('failed_at is null and run_at <= ?', Delayed::Job.db_time_now).order('run_at').first
    age = now - (first_unprocessed.nil? ? now : first_unprocessed.run_at)
    first_unprocessed_high_priority = Delayed::Job.where('failed_at is null and priority < 50 and run_at <= ?', Delayed::Job.db_time_now).order('run_at').first
    high_priority_oldest_job_age = now - (first_unprocessed_high_priority.nil? ? now : first_unprocessed_high_priority.run_at)
    queue_size = Delayed::Job.where('failed_at is null and run_at <= ?', Delayed::Job.db_time_now).count
    submit_queue_size = Delayed::Job.where('failed_at is null and queue = "submit" and run_at <= ?', Delayed::Job.db_time_now).count
    high_priority_queue_size = Delayed::Job.where('failed_at is null and priority < 50 and run_at <= ?', Delayed::Job.db_time_now).count

    errors = Delayed::Job.where('last_error is not null').count
    # HACK ALERT: much faster than .count(), but wrongish.
    flags = Flag.maximum(:id)

    metrics = [
      {:metric_name => "failed_jobs", :value => failed_jobs, :unit => "Count"},
      {:metric_name => "oldest_job_age", :value => age, :unit => "Seconds"},
      {:metric_name => "queue_size", :value => queue_size, :unit => "Count"},
      {:metric_name => "error_count", :value => errors, :unit => "Count"},
      {:metric_name => "submit_queue_size", :value => submit_queue_size, :unit => "Count"},
      {:metric_name => "high_priority_queue_size", :value => high_priority_queue_size, :unit => "Count"},
      {:metric_name => "high_priority_oldest_job_age", :value => high_priority_oldest_job_age, :unit => "Seconds"},
      {:metric_name => "flags_count", :value => flags, :unit => "Count"},
    ]

    # HACK ALERT: this will very much break if the app is reset or if there are multiple frontends.
    # flags_created should be considered an unreliable metric.
    if $LAST_FLAG_REPORT.nil?
      $LAST_FLAG_REPORT = flags
      new_flags = nil
    else
      new_flags = flags - $LAST_FLAG_REPORT
      $LAST_FLAG_REPORT = flags
      metrics << {:metric_name => "flags_created", :value => new_flags, :unit => "Count"}
    end
    cw = AWS::CloudWatch.new(:access_key_id => Settings.cloudwatch_key, :secret_access_key => Settings.cloudwatch_secret)
    cw.put_metric_data(
      :namespace => "4sweep_#{Rails.env}",
      :metric_data => metrics
    )
    Rails.logger.debug("Reported status to cloudwatch: [failed_jobs: #{failed_jobs}, oldest_job_age: #{age}," +
      " queue_size: #{queue_size}, error_count: #{errors}, flags_created: #{new_flags}]")
  end
end
