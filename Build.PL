use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Posy::Plugin::Pod',
    license             => 'perl',
    dist_author         => 'Kathryn Andersen',
    dist_version_from   => 'lib/Posy/Plugin/Pod.pm',
	requires            => {
	'Posy' => 0.40,
	'Posy::Plugin::EntryTitles' => 0.40,
	'Pod::Simple::HTML' => 3.01,
	},
    build_requires => {
        'Test::More' => 0,
    },
);

$builder->create_build_script();
# create the Makefile.PL if need be
if (! -f 'Makefile.PL')
{
    use Module::Build::Compat;
    print "creating Makefile.PL\n";
    Module::Build::Compat->create_makefile_pl('passthrough', $builder);
}
