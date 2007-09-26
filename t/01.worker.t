use Test::More tests => 6;
use lib qw(lib);

{

    package Manager;
    use Moose;
    with qw(MooseX::Workers);

    sub worker_manager_start {
        ::pass('started worker manager');
    }

    sub worker_manager_stop {
        ::pass('stopped worker manager');
    }

    sub worker_stdout {
        my ( $self, $output ) = @_;
        ::is( $output, 'HELLO' );
    }

    sub worker_stderr {
        my ( $self, $output ) = @_;
        ::is( $output, 'WORLD' );
    }
    sub worker_error {  }
    sub worker_done  { ::pass('worker done') }

    sub worker_started { ::pass('worker started') }
    no Moose;
}

my $m = Manager->new();
$m->spawn( sub { print "HELLO\n"; print STDERR "WORLD\n" } );
POE::Kernel->run();
