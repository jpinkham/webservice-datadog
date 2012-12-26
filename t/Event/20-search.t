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
	: plan( tests => 11 );

my $config = DataDogConfig->new();

# Create an object to communicate with DataDog
my $datadog = WebService::DataDog->new( %$config );
ok(
	defined( $datadog ),
	'Create a new WebService::DataDog object.',
);


my $event_obj = $datadog->build('Event');
ok(
	defined( $event_obj ),
	'Create a new WebService::DataDog::Event object.',
);
my $response;


throws_ok(
	sub
	{
		$response = $event_obj->search();
	},
	qr/Argument.*required/,
	'Dies on missing "start" argument.',
);

throws_ok(
	sub
	{
		$response = $event_obj->search( start => "abc" );
	},
	qr/nvalid.*start/,
	'Dies on invalid start time.',
);

throws_ok(
	sub
	{
		$response = $event_obj->search(
			start => time(),
			end   => "abc",
		);
	},
	qr/nvalid.*end/,
	'Dies on invalid end time.',
);


throws_ok(
	sub
	{
		$response = $event_obj->search(
			start    => time(),
			priority => "nuclear",
		);
	},
	qr/nvalid.*priority/,
	'Dies on invalid priority.',
);

throws_ok(
	sub
	{
		$response = $event_obj->search(
			start => time(),
			tags  => "tags_go_here",
		);
	},
	qr/ag list.*arrayref/,
	'Dies on invalid tag list.',
);

throws_ok(
	sub
	{
		$response = $event_obj->search(
			start   => time(),
			sources => "sources_go_here",
		);
	},
	qr/ources.*arrayref/,
	'Dies on invalid sources list.',
);


lives_ok(
	sub
	{
		$response = $event_obj->search( start => time() - ( 30 * 24 * 60 * 60 ) );
	},
	'Search events for last 30 days.',
);

ok(
	defined( $response ),
	'Response was received.'
);

ok(
	Data::Validate::Type::is_arrayref( $response ),
	'Response is an arrayref.',
);

