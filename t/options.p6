
use Test;

use Shell::Application;

my $cmd = Shell::Application.new;

$cmd.add-option: Shell::Application::Option.new(
  :long('debug'),
  :short('d'),
  :description('enable debug mode'),
  :type(Shell::Application::Option::Flag)
);

$cmd.add-option: Shell::Application::Option.new(
  :long('int'),
  :short('i'),
  :description('some number'),
  :type(Shell::Application::Option::Integer)
);

$cmd.add-option: Shell::Application::Option.new(
  :long('string'),
  :short('s'),
  :description('some string'),
  :type(Shell::Application::Option::String)
);

$cmd.add-option: Shell::Application::Option.new(
  :long('count'),
  :short('c'),
  :description('flag that can be used multiple times'),
  :type(Shell::Application::Option::Count)
);

$cmd.parse-options(
  ['-d', '-i', '123', '-s', 'foo', '-c', '-c', '-cc']
);

is($cmd.get-option(:long('debug')).value, True, 'debug mode is on (long)');
is($cmd.get-option(:short('d')).value, True, 'debug mode is on (short)');
is($cmd.get-option(:long('int')).value, 123, 'integer (long)');
is($cmd.get-option(:short('i')).value, 123, 'integer (short)');
is($cmd.get-option(:long('string')).value, 'foo', 'string (long)');
is($cmd.get-option(:short('s')).value, 'foo', 'string (short)');
is($cmd.get-option(:long('count')).value, 4, 'count (long)');
is($cmd.get-option(:short('c')).value, 4, 'count (short)');

# Reset options.
$_.value = False for $cmd.options;

$cmd.parse-options(
  ['--debug', '--int', '123', '--string', 'foo', '--count', '--count', '--count', '--count']
);

is($cmd.get-option(:long('debug')).value, True, 'debug mode is on (long)');
is($cmd.get-option(:short('d')).value, True, 'debug mode is on (short)');
is($cmd.get-option(:long('int')).value, 123, 'integer (long)');
is($cmd.get-option(:short('i')).value, 123, 'integer (short)');
is($cmd.get-option(:long('string')).value, 'foo', 'string (long)');
is($cmd.get-option(:short('s')).value, 'foo', 'string (short)');
is($cmd.get-option(:long('count')).value, 4, 'count (long)');
is($cmd.get-option(:short('c')).value, 4, 'count (short)');

# Reset options.
$_.value = False for $cmd.options;

$cmd.parse-options(
  ['--debug', '--int=123', '--string=foo', '--count', '--count', '--count', '--count']
);

is($cmd.get-option(:long('debug')).value, True, 'debug mode is on (long)');
is($cmd.get-option(:short('d')).value, True, 'debug mode is on (short)');
is($cmd.get-option(:long('int')).value, 123, 'integer (long)');
is($cmd.get-option(:short('i')).value, 123, 'integer (short)');
is($cmd.get-option(:long('string')).value, 'foo', 'string (long)');
is($cmd.get-option(:short('s')).value, 'foo', 'string (short)');
is($cmd.get-option(:long('count')).value, 4, 'count (long)');
is($cmd.get-option(:short('c')).value, 4, 'count (short)');

# Reset options.
$_.value = False for $cmd.options;

$cmd.parse-options(
  ['-di', '123', '-ccccsfoo']
);

is($cmd.get-option(:long('debug')).value, True, 'debug mode is on (long)');
is($cmd.get-option(:short('d')).value, True, 'debug mode is on (short)');
is($cmd.get-option(:long('int')).value, 123, 'integer (long)');
is($cmd.get-option(:short('i')).value, 123, 'integer (short)');
is($cmd.get-option(:long('string')).value, 'foo', 'string (long)');
is($cmd.get-option(:short('s')).value, 'foo', 'string (short)');
is($cmd.get-option(:long('count')).value, 4, 'count (long)');
is($cmd.get-option(:short('c')).value, 4, 'count (short)');

done-testing;
