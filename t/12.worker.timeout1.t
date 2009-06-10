use Test::More tests => 7;
use lib qw(lib);
use strict;

# This timeout demonstration covers the case where the timeout is envoked before the
# child exits on it's own. 

my $starttime = time;
# print "starttime is $starttime\n";

{
    package Manager;
    use MooseX::Workers::Job;
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
        ::is( $output, "HELLO", "STDOUT" );
    }

    sub worker_stderr {
        my ( $self, $output, $wheel ) = @_;
        ::is( $output, "WORLD", "STDERR" );
    }

    sub worker_error { ::fail('Got error?'.@_) }

    sub worker_timeout  { 
        my ( $self, $job ) = @_;
        ::pass("worker timeout");
    }

    sub worker_done  { 
        my ( $self, $job ) = @_;
        my $now = time;
        ::cmp_ok($now, '<=', $starttime + 2, "worker done in <= 2 seconds");
    }

    sub worker_started { 
        my ( $self, $job ) = @_;
        ::pass("worker started");
    }
    
    sub run { 
        my $job = MooseX::Workers::Job->new(
            timeout => 1,
            command => sub { print "HELLO\n"; print STDERR "WORLD\n"; sleep 3; },
        );
        $_[0]->run_command( $job );
        POE::Kernel->run();
    }
    no Moose;
}

Manager->new()->run();


