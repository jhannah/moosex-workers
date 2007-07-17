package MooseX::Workers::Engine;
use strict;
use Moose;
use POE qw(Wheel::Run);
use MooseX::AttributeHelpers;

has visitor => (
    is       => 'ro',
    required => 1,
    does     => 'MooseX::Workers',
);

has workers => (
    isa       => 'HashRef',
    is        => 'rw',
    lazy      => 1,
    required  => 1,
    default   => sub { {} },
    metaclass => 'Collection::Hash',
    provides  => {
        'set'    => 'set_worker',
        'get'    => 'get_worker',
        'delete' => 'delete_worker',
        'empty'  => 'has_workers',
        'count'  => 'num_workers',
    },
);

has session => (
    isa      => 'POE::Session',
    is       => 'ro',
    required => 1,
    weaken   => 1,
    default  => sub {
        POE::Session->create(
            object_states => [
                $_[0] => [
                    qw(
                      _start
                      _stop
                      _worker_stdout
                      _worker_stderr
                      _worker_error
                      _worker_done
                      add_worker
                      )
                ],
            ],
        );
    },
    clearer => 'clear_session',
);

sub yield {
    my $self = shift;
    $poe_kernel->post( $self->session => @_ );
}

#
# EVENTS
#

sub add_worker {
    my ( $self, $command ) = @_[ OBJECT, ARG0 ];
    my $wheel = POE::Wheel::Run->new(
        Program     => $command,
        StdoutEvent => '_worker_stdout ',
        StderrEvent => '_worker_stderr',
        ErrorEvent  => '_worker_error',
        CloseEvent  => '_worker_done',
    );
    $self->set_worker( $wheel->ID => $wheel );
    $self->visitor->worker_started( $wheel->ID => $command );

}

sub _start {
    my ($self) = $_[OBJECT];
    $self->visitor->worker_manager_start();
}

sub _stop {
    my ($self) = $_[OBJECT];
    $self->visitor->worker_manager_stop();
    $self->clear_session;
}

sub _worker_stdout {
    my ($self) = $_[OBJECT];
    $self->visitor->worker_stdout( @_[ ARG0, ARG1 ] );    # $input, $wheel_id
}

sub _worker_stderr {
    my ($self) = $_[OBJECT];
    $_[ARG1] =~ tr[ -~][]cd;
    $self->visitor->worker_stderr( @_[ ARG0, ARG1 ] );    # $input, $wheel_id
}

sub _worker_error {
    my ($self) = $_[OBJECT];

    # $operation, $errnum, $errstr, $wheel_id
    $self->visitor->worker_error( @_[ ARG0 .. ARG3 ] );
}

sub _worker_done {
    my ($self) = $_[OBJECT];
    $self->visitor->worker_done( $_[ARG0] );
    $self->delete_worker( $_[ARG0] );
}

no Moose;
1;
__END__
