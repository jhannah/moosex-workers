package MooseX::Workers;
use Moose::Role;
our $VERSION = '0.05';

use MooseX::Workers::Engine;

has Engine => (
    isa      => 'MooseX::Workers::Engine',
    is       => 'ro',
    lazy     => 1,
    required => 1,
    default  => sub { MooseX::Workers::Engine->new( visitor => $_[0] ) },
    handles  => [
        qw(
          max_workers
          has_workers
          num_workers
          put_worker
          kill_worker
          get_worker
          )
    ],
);

sub spawn {
    my ( $self, $cmd, $args ) = @_;
    return $self->Engine->call( add_worker => $cmd => $args );
}

__PACKAGE__->meta->add_method( 'fork' => __PACKAGE__->can('spawn') );

sub run_command {
    my ( $self, $cmd ) = @_;
    $self->Engine->yield( add_worker => $cmd );
}

sub check_worker_threshold {
    return $_[0]->num_workers >= $_[0]->max_workers;
}

sub check_worker_threashold {
    warn 'check_worker_threashold is deprecated '
      . 'please use check_worker_threshold instead';
    shift->check_worker_threshold;
}

no Moose::Role;
1;
__END__

=head1 NAME

MooseX::Workers - Provides a simple sub-process management for asynchronous tasks.


=head1 VERSION

This document describes MooseX::Workers version 0.0.1


=head1 SYNOPSIS

    package Manager;
    use Moose;
    with qw(MooseX::Workers);

    sub run {
        $_[0]->spawn( sub { sleep 3; print "Hello World\n" } );
        warn "Running now ... ";
        POE::Kernel->run();
    }

    # Implement our Interface
    sub worker_manager_start { warn 'started worker manager' }
    sub worker_manager_stop  { warn 'stopped worker manager' }
    sub max_workers_reached  { warn 'maximum worker count reached' }

    sub worker_stdout  { shift; warn join ' ', @_; }
    sub worker_stderr  { shift; warn join ' ', @_; }
    sub worker_error   { shift; warn join ' ', @_; }
    sub worker_done    { shift; warn join ' ', @_; }
    sub worker_started { shift; warn join ' ', @_; }
    sub sig_child      { shift; warn join ' ', @_; }
    no Moose;

    Manager->new->run();
  
=head1 DESCRIPTION

MooseX::Workers is a Role that provides easy delegation of long-running tasks 
into a managed child process. Process managment is taken care of via POE and it's 
POE::Wheel::Run module.


=head1 METHODS

=over 

=item spawn ($command)
=item fork ($command)
=item run_command ($command)

This is the whole point of this module. This will pass $command through to the 
MooseX::Worker::Engine which will take care of running this asynchronously.


=item check_worker_threshold

This will check to see how many workers you have compared to the max_workers limit. It returns true
if the $num_workers is >= $max_workers;

=item max_workers($count)

An accessor for the maxium number of workers. This is delegated to the MooseX::Workers::Engine object.

=item has_workers

Check to see if we have *any* workers currently. This is delegated to the MooseX::Workers::Engine object.

=item num_workers

Return the current number of workers. This is delegated to the MooseX::Workers::Engine object.

=item meta

The Metaclass for MooseX::Workers::Engine see Moose's documentation.

=back

=head1 INTERFACE 

MooseX::Worker::Engine supports the following callbacks:

=over

=item worker_manager_start

Called when the managing session is started

=item worker_manager_stop

Called when the managing session stops

=item max_workers_reached

Called when we reach the maximum number of workers

=item worker_stdout

Called when a child prints to STDOUT

=item worker_stderr

Called when a child prints to STDERR

=item worker_error

Called when there is an error condition detected with the child.

=item worker_done

Called when a worker completes $command

=item worker_started

Called when a worker starts $command

=item sig_child

Called when the mangaging session recieves a SIG CHDL event

=back

See MooseX::Workers::Engine for more details.

=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
    A full explanation of any configuration system(s) used by the
    module, including the names and locations of any configuration
    files, and the meaning of any environment variables or properties
    that can be set. These descriptions must also include details of any
    configuration language used.
  
MooseX::Workers requires no configuration files or environment variables.


=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

Moose, POE, POE::Wheel::Run


=head1 INCOMPATIBILITIES

=for author to fill in:
    A list of any modules that this module cannot be used in conjunction
    with. This may be due to name conflicts in the interface, or
    competition for system or program resources, or due to internal
    limitations of Perl (for example, many modules that use source code
    filters are mutually incompatible).

None reported.


=head1 BUGS AND LIMITATIONS

=for author to fill in:
    A list of known problems with the module, together with some
    indication Whether they are likely to be fixed in an upcoming
    release. Also a list of restrictions on the features the module
    does provide: data types that cannot be handled, performance issues
    and the circumstances in which they may arise, practical
    limitations on the size of data sets, special cases that are not
    (yet) handled, etc.

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-moosex-workers@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

Chris Prather  C<< <perigrin@cpan.org> >>

Tom Lanyon C<< <dec@cpan.org> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2007, Chris Prather C<< <perigrin@cpan.org> >>. Some rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
