package AuthSub;
use Ark;

our $VERSION = '0.01';

use_plugins qw(
    Session
    Session::State::Cookie
    Session::Store::Memory
);

1;
