#!perl -T

use strict;
use warnings;

use Data::Dumper;

use Data::Validate::Type;
use Test::Exception;
use Test::More;

use WebService::DataDog;


eval 'use DataDogConfig';
$@
	? plan( skip_all => 'Local connection information for DataDog required to run tests.' )
	: plan( tests => 5 );

my $config = DataDogConfig->new();

# Create an object to communicate with DataDog
my $datadog = WebService::DataDog->new( %$config );
ok(
	defined( $datadog ),
	'Create a new WebService::DataDog object.',
);

my $response;

dies_ok(
	sub
	{
		$response = $datadog->add_host_tags();
	},
	'Request tags - do not specify any parameters.',
);

dies_ok(
	sub
	{
		$response = $datadog->add_host_tags(
			host => 'unknown-host'
		);
	},
	'Request tags - do not specify tag parameter.',
);

dies_ok(
	sub
	{
		$response = $datadog->add_host_tags(
			tags => [ 'tag1', 'tag2' ]
		);
	},
	'Request tags - do not specify host parameter.',
);

dies_ok(
	sub
	{
		$response = $datadog->add_host_tags(
			host => 'hostname-goes-here',
			tags => 'tag2'
		);
	},
	'Request tags - specify incorrect tags parameter.',
);


# Specify a host that is not known to DataDog
dies_ok(
	sub
	{
		$response = $datadog->add_host_tags(
			host => 'hostname-goes-here',
			tags => [ 'tag2' ],
		);
	},
	'Request tags - specify known-bad host parameter.',
);


