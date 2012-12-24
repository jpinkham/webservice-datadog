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
	: plan( tests => 6 );

my $config = DataDogConfig->new();

# Create an object to communicate with DataDog
my $datadog = WebService::DataDog->new( %$config );
ok(
	defined( $datadog ),
	'Create a new WebService::DataDog object.',
);


my $dashboard_obj = $datadog->build('Dashboard');
ok(
	defined( $dashboard_obj ),
	'Create a new WebService::DataDog::Dashboard object.',
);


open( FILE, 'webservice-datadog-dashboard-dashid.tmp');
my $dash_id = do { local $/; <FILE> },
close FILE;
	
my $old_dash_info = $dashboard_obj->get_dashboard( id => $dash_id )->{'dash'};
my $response;


throws_ok(
	sub
	{
		$response = $dashboard_obj->update_dashboard( 
			title       => "TESTTITLE - " . $old_dash_info->{'title'}
		);
	},
	qr/Argument.*required/,
	'Dies without required argument "id"',
);

throws_ok(
	sub
	{
		$response = $dashboard_obj->update_dashboard( 
			id          => $dash_id,
			title       => "",
		);
	},
	qr/blank dashboard title/,
	'Dies with empty argument "title"',
);

lives_ok(
	sub
	{
		$response = $dashboard_obj->update_dashboard( 
			id          => $dash_id,
			title       => "TESTTITLE - " . $old_dash_info->{'title'}
		);
	},
	'Update - change title, providing required fields',
);


lives_ok(
	sub
	{
		$response = $dashboard_obj->update_dashboard(
			id     => $dash_id,
			graphs => [
				{
					title => "Sum of Memory Free",
					definition =>
					{
						events   =>[],
						requests => [
							{ q => "sum:system.mem.free{*}" }
						]
					},
					viz => "timeseries"
				}
			],
		);
	},
	'Update - change graphs on dashboard',
);
