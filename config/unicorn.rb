# Set the working application directory
working_directory "REPLACE_ME"

# Unicorn PID file location
pid "REPLACE_ME"

# Path to logs
stderr_path "REPLACE_ME"
stderr_path "REPLACE_ME"

# Unicorn socket
listen "/tmp/unicorn.4sweep.sock"

# Number of processes
# worker_processes 4
worker_processes 2

# Time-out
timeout 30
