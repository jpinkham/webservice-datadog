#!perl -T

use strict;
use warnings;

use Data::Dumper;

use Test::Exception;
use Test::More;

use WebService::DataDog;


eval 'use DataDogConfig';
$@
	? plan( skip_all => 'Local connection information for DataDog required to run tests.' )
	: plan( tests => 15 );

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
		$response = $event_obj->post_event();
	},
	qr/Argument.*required/,
	'Dies on missing arguments.',
);

throws_ok(
	sub
	{
		$response = $event_obj->post_event( title => "abc" );
	},
	qr/Argument.*text.*required/,
	'Dies on blank/missing "text" argument.',
);

throws_ok(
	sub
	{
		$response = $event_obj->post_event( 
			text => "yadda yadda",
			title => "",
		);
	},
	qr/Argument.*title.*required/,
	'Dies on blank/missing "title" argument.',
);

throws_ok(
	sub
	{
		$response = $event_obj->post_event(
			title => "yadda",
			text  => "",
		);
	},
	qr/Argument.*text.*required/,
	'Dies on blank/missing "text" argument.',
);

# Undocumented limitation, as of 12/27/2012.
dies_ok(
	sub
	{
		$response = $event_obj->post_event(
			text  => "SOmething something something",
			title => "TESTTITLETESTTITLETESTTITLETESTTITLETESTTITLE-ABCDEFGHIJKLMNOPQRSTUVWXYZ-ABCDEFGH",
		);
	},
	'Dies on title > 80 chars',
);

throws_ok(
	sub
	{
		$response = $event_obj->post_event(
			title           => "title goes here",
			text            => "Text goes here",
			date_happened   => "abc",
		);
	},
	qr/invalid.*date_happened/,
	'Dies on invalid "date_happened".',
);


throws_ok(
	sub
	{
		$response = $event_obj->post_event(
			title    => "title goes here",
			text     => "Text goes here",
			priority => "nuclear",
		);
	},
	qr/nvalid.*priority/,
	'Dies on invalid priority.',
);

throws_ok(
	sub
	{
		$response = $event_obj->post_event(
			title            => "title goes here",
			text             => "Text goes here",
			related_event_id => "abc",
		);
	},
	qr/nvalid.*related_event_id/,
	'Dies on invalid related_event_id.',
);

throws_ok(
	sub
	{
		$response = $event_obj->post_event(
			title => "title goes here",
			text  => "Text goes here",
			tags  => "tags_go_here",
		);
	},
	qr/ag list.*arrayref/,
	'Dies on invalid tag list.',
);

throws_ok(
	sub
	{
		$response = $event_obj->post_event(
			title      => "title goes here",
			text       => "Text goes here",
			alert_type => "kabooom",
		);
	},
	qr/nvalid.*alert_type/,
	'Dies on invalid alert_type.',
);

my $response;
lives_ok(
	sub
	{
		$response = $event_obj->post_event(
			title      => "title goes here",
			text       => "Text goes here",
		);
	},
	'Post valid event to stream.',
);

#TODO test with date_happened
#TODO test with priority
#TODO test with related_event_id
#TODO test with tags
#TODO test with alert_type
#TODO test with source_type_name



ok(
	defined( $response ),
	'Response was received.'
);

ok(
	Data::Validate::Type::is_hashref( $response ),
	'Response is an hashref.',
);

