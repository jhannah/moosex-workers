use Test::More tests => 1;
use lib qw(lib);

BEGIN {
use_ok( 'MooseX::Workers' );
}

diag( "Testing MooseX::Workers $MooseX::Workers::VERSION" );
