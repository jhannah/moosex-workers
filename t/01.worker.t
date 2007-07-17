use Test::More no_plan => 1;
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

    sub worker_output {
        my ( $self, $output ) = @_;
        ::pass($output);
    }

    no Moose;
}

my $m = Manager->new();
$m->run_command( sub { print "Testing\n" } );
POE::Kernel->run();
