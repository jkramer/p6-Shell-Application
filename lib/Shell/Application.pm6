
use Shell::Application::Command;

class Shell::Application is Shell::Application::Command {
  has Str $.name = $*PROGRAM-NAME;
}
