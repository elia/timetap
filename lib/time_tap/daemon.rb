# Define Process::daemon without waiting for active support to be loaded
# so that the "timetap" command exits immediatly.
# from active_support-3
def Process.daemon(nochdir = nil, noclose = nil)
  exit if fork                     # Parent exits, child continues.
  Process.setsid                   # Become session leader.
  exit if fork                     # Zap session leader. See [1].

  unless nochdir
    Dir.chdir "/"                  # Release old working directory.
  end

  File.umask 0000                  # Ensure sensible umask. Adjust as needed.

  unless noclose
    STDIN.reopen  '/dev/null'      # Free file descriptors and
    STDOUT.reopen '/dev/null', "a" # point them somewhere sensible.
    STDERR.reopen '/dev/null', 'a'
  end

  trap("TERM") { exit }

  return 0
end
