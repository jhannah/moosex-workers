use Test::More tests => 8;
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
        ::is( $output, 'HELLO', 'STDOUT' );
    }

    sub worker_stderr {
        my ( $self, $output ) = @_;
        ::is( $output, 'WORLD', 'STDERR' );
    }

    sub worker_error { ::fail('Got error?'.@_) }

    sub worker_done  { 
        my ( $self, $job ) = @_;
        ::is( $job->name, 'Foo',     '$job->name ' . $job->name );
        ::is( $job->ID,   1,         '$job->ID '   . $job->ID   );
        ::cmp_ok( $job->PID, '>', 0, '$job->PID '  . $job->PID  );
    }

    sub worker_started { ::pass('worker started') }
    
    sub run { 
        my $job = MooseX::Workers::Job->new(
           command => sub { print "HELLO\n"; print STDERR "WORLD\n" },
           name => 'Foo',
        );
        $_[0]->spawn( $job );
        POE::Kernel->run();
    }
    no Moose;
}

Manager->new()->run();
