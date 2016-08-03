
use Shell::Application::Option;

class Shell::Application::Command {
  my regex option-re-short { <[a..zA..Z]> }
  my regex option-re-long { <[a..zA..Z]> <[a..zA..Z-]>+ }

  has Str $.name;
  has Str $.description;
  has Str @.args;
  has Shell::Application::Option @.options;
  has Shell::Application::Command %.commands;
  has Shell::Application::Command $.parent is rw;

  method add-option(Shell::Application::Option $option) {
    @.options.push: $option;
  }

  method add-command(Shell::Application::Command $command) {
    $command.parent = self;
    %.commands{$command.name} = $command;
  }

  method has-commands {
    return %.commands.elems > 0;
  }

  method start(@args = @*ARGS) {
    self.parse-options(@args);

    if self.has-commands {
      if @.args {
        my $command-name = @.args.shift;

        if %.commands{$command-name} {
          %.commands{$command-name}.start(@.args);
        }
        else {
          self.abort: "Unknown command '$command-name'.";
        }
      }
      else {
        self.abort: "No command given.";
      }
    }
    else {
      self.run;
    }
  }

  method get-option(:$long, :$short, :$global) {
    my $option = first {
      ($long.defined && $long eq $_.long)
      ||
      ($short.defined && $short eq $_.short)
    }, @.options;

    return $option if $option.defined;

    if !$option.defined && $.parent.defined && $global {
      return $.parent.get-option(:$long, :$short, :$global);
    }

    return Shell::Application::Option:U;
  }

  method parse-options(@args is copy = @*ARGS) {
    while my $arg = @args.shift {
      last if $arg eq '--';

      if $arg ~~ /^\-\- <option=option-re-long> [ $<assignment> = \= [ $<value> = [.*] ] ]? $/ {
        my $option = self.get-option(:long($/<option>));

        self.abort: "Unknown option --$/<option>.\n" unless $option.defined;

        my $error = $option.set-value:
          $/<assignment> ?? $/<value>.Str !! ($option.needs-value ?? @args.shift !! Str:U);

        self.abort: $error.exception.message if !$error;
      }

      elsif $arg ~~ /^\- <option-re-short>/ {
        my @flags = $arg.comb[1..*];

        while my $flag = @flags.shift {
          my $option = first { $_.short eq $flag }, @.options;

          self.abort: "Unknown option -$flag.\n" unless $option.defined;

          if $option.needs-value {
            my $ok = $option.set-value: @flags.chars ?? @flags.splice.join !! @args.shift;

            self.abort: $ok.exception.message unless $ok;
          }
          else {
            $option.set-value: Str:U;
          }
        }
      }

      else {
        @.args.push: $arg;

        # Stop parsing options if there's a non-option argument and we have
        # sub-commands, so the sub-command can parse its own options.
        last if self.has-commands;
      }
    }

    @.args.append: @args;
  }

  # TODO Use actual options instead of "<options>" for usage message.
  method usage { "Usage: $.name <options> <arguments>" }

  method help {
    my $help = $.usage;

    if @.options {
      $help ~= "\n\nOPTIONS\n" ~ @.options.map({ $_.help }).join("\n\n");
    }

    if self.has-commands {
      $help ~= "\n\nCOMMANDS\n" ~ %.commands.values.map({ $_.help }).join("\n\n").lines.map({ "  $_" }).join("\n");
    }

    return $help;
  }

  method abort(Str $message) {
    note $message;
    note self.usage;

    exit -1;
  }

  method run { ... }
}
