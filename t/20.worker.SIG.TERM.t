use Test::More;
use lib qw(lib);
use strict;

if ($^O eq 'MSWin32') {
    plan skip_all => "$^O does not support signals";
}
else {
    plan tests => 14;
}

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
        kill "TERM", $$;    # Send the worker manager (myself) the TERM signal
    }
    
    sub worker_finished  { 
        my ( $self, $job ) = @_;
        ::pass("worker_finished");
    }

    sub run { 
        my $job = MooseX::Workers::Job->new(
            command => sub { if ($^O eq 'MSWin32') { binmode STDOUT; binmode STDERR; } print "HELLO\n"; print STDERR "WORLD\n"; },
        );
        $_[0]->run_command( $job );
        POE::Kernel->run();
    }
    no Moose;
}


# --------------------------------
# When we have no sig_TERM(), so we should fall back to our vanilla non-POE TERM trap.
# --------------------------------
$SIG{TERM} = sub { ::pass('non-POE TERM trapped') };
Manager->new()->run();

# --------------------------------
# But as soon as we define sig_TERM(), we should hit that one and not the Perl one.
# --------------------------------
$SIG{TERM} = sub { ::fail('non-POE TERM trapped') };
Manager->meta->add_method( sig_TERM => sub { 
   my ( $self, $job ) = @_;
   ::pass("worker manager trapped the TERM signal");
});
Manager->new()->run();


