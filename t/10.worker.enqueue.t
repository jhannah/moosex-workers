use Test::More tests => 13;
use lib qw(lib);
use strict;

my $starttime = time;
my $elapsed = {};
# print "starttime is $starttime\n";

{
    package Manager;
    use Moose;
    with qw(MooseX::Workers);

    sub worker_manager_start {
        ::pass('started worker manager');
    }

    sub worker_manager_stop {
        ::pass('stopped worker manager');
        ::cmp_ok($elapsed->{3}, '>', $elapsed->{1}, "worker 3 took at least 1s longer than worker 1");
        ::cmp_ok($elapsed->{3}, '>', $elapsed->{2}, "worker 3 took at least 1s longer than worker 2");
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
        my $now = time;
        $elapsed->{$wheel} = $now - $starttime;
    }

    sub worker_started { 
        my ( $self, $wheel ) = @_;
        ::pass("worker $wheel started");
    }
    
    sub run { 
        for my $num (1..3) {
            $_[0]->enqueue( sub { 
                print "HELLO $num\n"; 
                print STDERR "WORLD $num\n"; 
                sleep 1;
            } );
        }
        POE::Kernel->run();
    }
    no Moose;
}

my $Manager = Manager->new();
$Manager->max_workers(2);    # Third job should have to wait for the second round of processing.
$Manager->run();


