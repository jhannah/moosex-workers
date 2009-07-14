package MooseX::Workers::Job;

use Moose;
has 'ID'      => ( is => 'rw', isa => 'Int' );   # POE::Wheel::Run->ID
has 'PID'     => ( is => 'rw', isa => 'Int' );   # POE::Wheel::Run->PID
has 'name'    => ( is => 'rw', isa => 'Str' );
has 'command' => ( is => 'rw', isa => 'CodeRef|Str|ArrayRef' );  # See POE::Wheel::Run POD (Program)
has 'args'    => ( is => 'rw', isa => 'ArrayRef' );              # See POE::Wheel::Run POD (ProgramArgs)
has 'timeout' => ( is => 'rw', isa => 'Int' );   # abort after this many seconds
no Moose;


=head1 NAME

MooseX::Workers::Job - One of the jobs MooseX::Workers is running

=head1 SYNOPSIS

  package Manager;
  use Moose;
  with qw(MooseX::Workers);

  sub worker_stdout {
      my ( $self, $output, $job ) = @_;
      printf(
          "%s(%s,%s) said '%s'\n",
          $job->name, $job->ID, $job->PID, $output
      );
  }
  sub run { 
      foreach (qw( foo bar baz )) {
          my $job = MooseX::Workers::Job->new(
             name    => $_,
             command => sub { print "Hello World\n" },
             timeout => 30,
          );
          $_[0]->spawn( $job );
      }
      POE::Kernel->run();
  }
  no Moose;

  Manager->new()->run();   
  # bar(2,32423) said 'Hello World'
  # foo(1,32422) said 'Hello World'
  # baz(3,32424) said 'Hello World'

=head1 DESCRIPTION

MooseX::Workers::Job objects are convenient if you want to name each
L<MooseX::Workers> job, or if you want them to timeout (abort) 
after a certain number of seconds.


=head1 AUTHORS

Jay Hannah C<< <jay@jays.net> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009, Chris Prather C<< <perigrin@cpan.org> >>. Some rights reserved.

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

=cut


1;

