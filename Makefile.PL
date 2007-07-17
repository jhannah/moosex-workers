use inc::Module::Install;
WriteMakefile(
    NAME                => 'MooseX::Workers',
    AUTHOR              => 'Chris Prather <perigrin@cpan.org>',
    VERSION_FROM        => 'lib/MooseX/Workers.pm',
    ABSTRACT_FROM       => 'lib/MooseX/Workers.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'MooseX-Workers-*' },
);
