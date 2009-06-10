package MooseX::Workers::Job;

use Moose;
has 'ID'      => ( is => 'rw', isa => 'Int' );   # POE::Wheel::Run->ID
has 'PID'     => ( is => 'rw', isa => 'Int' );   # POE::Wheel::Run->PID
has 'name'    => ( is => 'rw', isa => 'Str' );
has 'command' => ( is => 'rw', isa => 'CodeRef' );
has 'args'    => ( is => 'rw', isa => 'HashRef' );
has 'timeout' => ( is => 'rw', isa => 'Int' );   # abort after this many seconds
no Moose;

1;

