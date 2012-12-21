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
	: plan( tests => 4 );

my $config = DataDogConfig->new();

# Create an object to communicate with DataDog
my $datadog = WebService::DataDog->new( %$config );
ok(
	defined( $datadog ),
	'Create a new WebService::DataDog object.',
);

my $metric_obj = $datadog->build('Metric');
ok(
	defined( $metric_obj ),
	'Create a new WebService::DataDog::Metric object.',
);

isa_ok(
	$metric_obj,
	'WebService::DataDog::Metric',
	'Validated object instance of WebService::DataDog::Metric',
);

lives_ok(
	sub
	{
		$metric_obj->post_metric(
			name  => 'testmetric.test_gauge',
			value => 42
		);
	},
	'post metric - single data point, no timestamp.',
);

