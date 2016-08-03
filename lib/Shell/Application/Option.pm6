
use Text::Wrap;

class Shell::Application::Option {
  enum OptionType <Flag Count Integer String>;

  my regex short-flag-re { <[a..zA..Z]> }
  my regex long-flag-re { <[a..zA..Z]> <[a..zA..Z-]>+ }

  has Str $.short where m/^ <short-flag-re> $/;
  has Str $.long where m/^ <long-flag-re> $/;
  has Str $.description;
  has OptionType $.type;
  has $.value is rw = False;

  method needs-value {
    $.type ~~ any [Integer, String]
  }

  method set-value(Str $value) {
    if self.needs-value {
      fail self.as-string ~ " expects value" unless $value.defined;
      $.value = $value;

      given $.type {
        when Integer {
          fail self.as-string ~ " expects integer" unless $value ~~ /^ \d+ $/;
        }
      }
    }
    else {
      fail self.as-string ~ " doesn't expect a value" if $value.defined;
      given $.type {
        when Flag {
          $.value = True;
        }
        when Count {
          $.value += 1;
        }
      }
    }

    return True;
  }

  method as-string {
    my $short = $.short.defined ?? ('-' ~ $.short) !! Str:U;
    my $long = $.long.defined ?? ('--' ~ $.long) !! Str:U;
    return [$short, $long].grep({ $_.defined }).join('/');
  }

  method help {
    self.as-string ~ "\n  " ~ wrap-text($.description, :hard-wrap, :prefix('  '), :width(78));
  }

  method Str { $.value.Str }

  method Int { $.value.Int }

  method Bool { $.value.Bool }
}
