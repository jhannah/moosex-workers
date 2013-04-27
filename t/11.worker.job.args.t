use Test::More tests => 2;
use lib qw(lib);

# Testing command + args

{

    package Manager;
    use Moose;
    with qw(MooseX::Workers);

    sub worker_stdout {
        my ( $self, $output ) = @_;

        # remove CR
        $output =~ s/\015\z// if $^O eq 'MSWin32';

        ::is( $output, 7, 'STDOUT' );
    }

    sub worker_started { ::pass('worker started') }
    
    sub run { 
        my $job = MooseX::Workers::Job->new(
           command => ($^O eq 'MSWin32' ? 'cmd /c "echo"' : 'echo'),
           args    => [ 7 ],
           name    => 'Foo',
        );
        $_[0]->spawn( $job );
        POE::Kernel->run();
    }
    no Moose;
}

Manager->new()->run();
