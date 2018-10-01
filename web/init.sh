# Start supervisord
supervisord --configuration=/etc/supervisord.conf

# Execute all commands
exec "$@";
