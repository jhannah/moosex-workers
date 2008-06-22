# Load the Module::Install bundled in ./inc/
use inc::Module::Install 0.75;

# Define metadata
name 'MooseX-Workers';
all_from 'lib/MooseX/Workers.pm';

# Specific dependencies
requires 'Moose'                    => '0';
requires 'MooseX::AttributeHelpers' => '0';
requires 'POE'                      => '0';

build_requires 'Test::More' => '0.42';

no_index 'directory' => 'ex';

auto_install;
WriteAll;
