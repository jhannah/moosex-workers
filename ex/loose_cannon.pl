#!/usr/bin/env perl 
$|++;

package LooseCannon::Cannon;

use Moose;
use Moose::Util::TypeConstraints;

has id => (
    is       => 'ro',
    isa      => 'Int',
    required => 1
);

has delay => (
    is      => 'ro',
    isa     => 'Int',
    lazy    => 1,
    default => sub {
        5 + int( rand(5) );
    }
);

has fired => (
    is      => 'rw',
    isa     => 'Bool',
    lazy    => 1,
    default => 0
);

sub tag {
    return 'Cannon(' . $_[0]->id . ')';
}

sub load {
    print $_[0]->tag . " is loading, will take ", $_[0]->delay, " seconds\n";
    sleep( $_[0]->delay );
    $_[0]->fired(1);
}

sub fire {
    return $_[0]->can('commence_firing');
}

sub commence_firing {
    $_[0]->load;
    print $_[0]->tag . " goes KA-BOOM!\n";
}

no Moose;
1;

package LooseCannon::Gunner;

use Moose;
use Moose::Util::TypeConstraints;

with 'MooseX::Workers';

has 'guns' => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub { {} }
);

sub worker_started {

    #	print "Gunner instructed to fire: ",join(',',@_),"\n";
    print "Worker-Started: ", $_[0]->Engine->get_worker( $_[1] ), "\n";
}

sub worker_done {
    print "Gunner done firing: ", join( ',', @_ ), "\n";
    print "Worker-Done: ", $_[0]->Engine->get_worker( $_[1] ), "\n";
}

sub max_workers_reached {
    print "Max workers reached: ", join( ',', @_ ), "\n";
}

sub worker_stdout { print "Got @_", "\n" }

sub execute {
    my $cannon = new LooseCannon::Cannon( { id => $_[1] } );

    print "Finished building ", $cannon->tag, "\n";
    use Data::Dumper;
    my $r = $_[0]->spawn( $cannon->fire, $cannon );
    warn "SPAWN: ", Dumper($r), "\n";
}

no Moose;
1;

package LooseCannon;

use MooseX::POE;

has count => (
    is      => 'rw',
    isa     => 'Int',
    lazy    => 1,
    default => 0
);

has gunner => (
    is      => 'ro',
    isa     => 'LooseCannon::Gunner',
    lazy    => 1,
    default => sub {
        return new LooseCannon::Gunner;
    }
);

has tell_freq => (
    is      => 'rw',
    isa     => 'Int',
    default => 3
);

sub ts {
    return scalar(localtime);
}

sub kernel {
    return 'POE::Kernel';
}

sub add_count {
    $_[0]->count( $_[0]->count + 1 );
}

sub would_tell {
    ( int( rand( $_[0]->tell_freq ) ) + 1 ) % $_[0]->tell_freq == 0;
}

event tell_gunner => sub {
    print "Telling gunner ", $_[0]->ts, "\n";
    $_[0]->gunner->execute( $_[0]->count );
};

event tick => sub {
    print "Tick(", $_[0]->add_count, ") ", $_[0]->ts, "\n";
    $_[0]->kernel->alarm_add( 'tock' => time() + 1 );
    $_[0]->yield('tell_gunner') if $_[0]->would_tell;
};

event tock => sub {
    print "Tock(", $_[0]->add_count, ") ", $_[0]->ts, "\n";
    $_[0]->kernel->alarm_add( 'tick' => time() + 1 );
    $_[0]->yield('tell_gunner') if $_[0]->would_tell;
};

sub START {
    $_[0]->yield('tick');
}

sub run {
    run POE::Kernel;
}

no MooseX::POE;

__PACKAGE__->new->run;

