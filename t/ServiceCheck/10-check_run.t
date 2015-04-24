#!perl -T

use strict;
use warnings;

use Data::Dumper;
use Data::Validate::Type;
use Test::Exception;
use Test::Most 'bail';
use WebService::DataDog;


eval 'use DataDogConfig';
$@
	? plan( skip_all => 'Local connection information for DataDog required to run tests.' )
	: plan( tests => 4 );

my $config = DataDogConfig->new();

# Create an object to communicate with DataDog
my $datadog = WebService::DataDog->new( %$config );
ok(
	defined( $datadog ),
	'Create a new WebService::DataDog object.',
);


my $service_check_obj = $datadog->build('ServiceCheck');
ok(
	defined( $service_check_obj ),
	'Create a new WebService::DataDog::ServiceCheck object.',
);

my $response;

throws_ok(
	sub
	{
		$response = $service_check_obj->check_run();
	},
	qr/Argument.*required/,
	'Dies without required arguments',
);


throws_ok(
	sub
	{
		$response = $service_check_obj->check_run(
			check     => "WebService::DataDog::ServiceCheck unit test - check name goes here",
			host_name => "abcd",
			status    => "status"
		);
	},
	qr/'status' is invalid/,
	'Dies on invalid status',
);


