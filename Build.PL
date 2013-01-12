use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
	module_name          => 'WebService::DataDog',
	license              => 'artistic',
	dist_author          => q|Jennifer Pinkham <jpinkham@cpan.org>|,
	dist_version_from    => 'lib/WebService/DataDog.pm',
	build_requires       =>
	{
		'Test::More'           => 0.94,
	},
	requires             =>
	{
		'Carp'                 => 0,
		'Data::Dumper'         => 0,
		'Data::Validate::Type' => "1.1.0",
		'HTTP::Request'        => 0,
		'JSON'                 => 0,
		'LWP::UserAgent'       => 0,
		'Try::Tiny'            => 0,
		'Class::Load'          => 0,
		'perl' => 5.006,
	},
	add_to_cleanup       => [ 'WebService-DataDog-*' ],
	create_makefile_pl   => 'traditional',
	recursive_test_files => 1,
	configure_requires   =>
	{
		'Module::Build'  => 0,
	},
	meta_merge           =>
	{
		resources        =>
		{
			repository  => 'https://github.com/jpinkham/webservice-datadog.git',
			homepage    => 'https://metacpan.org/release/WebService-DataDog',
			bugtracker  => 'http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WebService-DataDog',
		},
	},
);

$builder->create_build_script();
