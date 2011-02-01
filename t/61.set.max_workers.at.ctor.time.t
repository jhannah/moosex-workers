#!/usr/bin/perl

use lib '../lib';
use lib 'lib';
use BaseClass::Subclass;
use Test::More;

sub make_man { BaseClass::Subclass->new( @_ ) }

is( make_man()->max_workers, 20, "Should default to 20 max_workers when no value specified" );
is( make_man( max_workers => 10 )->max_workers, 10, "Should have 10 max_workers when so specified" );

done_testing();
