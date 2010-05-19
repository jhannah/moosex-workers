use Test::More tests => 202;
use lib qw(lib);
use strict;

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
        my ( $self, $output, $wheel ) = @_;
        ::is( $output, "HELLO $wheel", "STDOUT $wheel" );
    }

    sub worker_stderr {
        my ( $self, $output, $wheel ) = @_;
        ::is( $output, "WORLD $wheel", "STDERR $wheel" );
    }

    sub worker_error { ::fail('Got error?'.@_) }

    sub worker_done  { 
        my ( $self, $wheel ) = @_;
        # ::pass("worker $wheel done");
        my $num = $self->num_workers;
        ::cmp_ok($num, '<=', 3, "num_workers: $num <= 3");
    }

    sub worker_started { 
        my ( $self, $wheel ) = @_;
        # ::pass("worker $wheel started");
        my $num = $self->num_workers;
        ::cmp_ok($num, '<=', 3, "num_workers: $num <= 3");
    }
    
    sub run { 
        for my $num (1..50) {
            $_[0]->enqueue( sub {
                if ($^O eq 'MSWin32') {
                    binmode STDOUT;
                    binmode STDERR;
                } 
                print "HELLO $num\n"; 
                print STDERR "WORLD $num\n"; 
            } );
        }
        POE::Kernel->run();
    }
    no Moose;
}

my $Manager = Manager->new();
$Manager->max_workers(3);    # Third job should have to wait for the second round of processing.
$Manager->run();


