function rt () {
  if [ -n "${BUNDLE_GEMFILE}" ]
  then
    # This is a Rails3 project - it is run by `bundle exec`
    ruby -I"lib:test" "$@"
  else
    # This is a Rails1 project. No bundler.
    ruby -e 'ARGV.each { |f| load f unless f =~ /^-/ ; break if f == "-n" }' "$@"
  fi
}
