package inc::MooseXWorkersMaker;

use Moose;
use Data::Dumper;

extends 'Dist::Zilla::Plugin::MakeMaker::Awesome';

override _build_WriteMakefile_dump => sub {
    my ($self) = @_;

    my $dump = super();

    $dump .= <<'EOF';

$WriteMakefileArgs{PREREQ_PM} = {
    %{ $WriteMakefileArgs{PREREQ_PM} },
    ($^O eq 'MSWin32' ? ('Win32::ShellQuote' => 0) : ())
};

EOF

    return $dump;
};

__PACKAGE__->meta->make_immutable;

no Moose;

1; # End of inc::MooseXWorkersMaker
