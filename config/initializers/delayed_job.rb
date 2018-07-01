Delayed::Worker.logger = Rails.logger
Delayed::Worker.max_attempts = 10
Delayed::Worker.max_run_time = 2.minutes
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 30
