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
	: plan( tests => 7 );

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

#TODO - add dies_ok checks for invalid/missing params and other errors

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

lives_ok(
	sub
	{
		$metric_obj->post_metric(
			name        => 'testmetric.test_gauge',
			data_points => [ [ ( time() - 100 ), 3.41 ] ],
		);
	},
	'post metric - single data point, with timestamp in past.',
);


lives_ok(
	sub
	{
		$metric_obj->post_metric(
			name        => 'testmetric.test_gauge',
			data_points => [ 
				[ ( time() - 100 ), 2.71828 ],
				[ ( time() ), 3.41 ],
				[ ( time() - 50 ), 47 ],
			],
		);
	},
	'post metric - multiple data points.',
);

lives_ok(
	sub
	{
		$metric_obj->post_metric(
			name  => 'testmetric.test_gauge',
			value => 3.41,
			host  => 'test-host',
			tags  => [ 'dev', 'env:testing' ],
		);
	},
	'post metric - single data point, with host and tags.',
);

