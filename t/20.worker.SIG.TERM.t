use Test::More tests => 7;
use lib qw(lib);
use strict;

# If I have no sig_term() sub then nothing happens when I SIG TERM myself.

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

    sub worker_started { 
        my ( $self, $job ) = @_;
        ::pass("worker started");
        kill "TERM", $$;    # Send the worker manager the TERM signal
    }
    
    sub sig_TERM  { 
        my ( $self, $job ) = @_;
        ::pass("worker manager trapped the TERM signal");
    }

    sub worker_done  { 
        my ( $self, $job ) = @_;
        ::pass("worker_done");
    }

    sub run { 
        my $job = MooseX::Workers::Job->new(
            command => sub { print "HELLO\n"; print STDERR "WORLD\n"; },
        );
        $_[0]->run_command( $job );
        POE::Kernel->run();
    }
    no Moose;
}

Manager->new()->run();


