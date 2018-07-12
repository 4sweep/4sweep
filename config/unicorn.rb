# Set the working application directory
working_directory "/home/4sweep/REPLACE_ME"

# Unicorn PID file location
pid "REPLACE_ME"

# Path to logs
stderr_path "/REPLACE_ME"
stderr_path "/data/log/REPLACE_ME"

# Unicorn socket
listen "/tmp/unicorn.4sweep.sock"

# Number of processes
# worker_processes 4
worker_processes 2

# Time-out
timeout 30
