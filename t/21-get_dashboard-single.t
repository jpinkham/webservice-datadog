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
	: plan( tests => 9 );

my $config = DataDogConfig->new();

# Create an object to communicate with DataDog
my $datadog = WebService::DataDog->new( %$config );
ok(
	defined( $datadog ),
	'Create a new WebService::DataDog object.',
);


# Pull a known dashboard id from temp file, determined in previous test
ok(
	open( FILE, 'business-datadog-dashboard-dashid.tmp'),
	'Open temp file to read dashboard id'
);

my $known_dashboard_id;

ok(
	$known_dashboard_id = do { local $/; <FILE> },
	'Read in known dashboard id'
);

ok(
	close FILE,
	'Close temp file'
);


my $response;
lives_ok(
	sub
	{
		$response = $datadog->get_dashboard( id => $known_dashboard_id );
	},
	'Request specific dashboard details.',
);

ok(
	Data::Validate::Type::is_hashref( $response ),
	'Retrieve response.',
) || diag( explain( $response ) );

ok(
	defined( $response->{'dashes'} ),
	'We have a "dashes" block in the response.',
);

ok(
	Data::Validate::Type::is_arrayref( $response->{'dashes'} ),
	'"dashes" block is an arrayref.',
);

is(
	$response->{'dashes'}->[0]->{'id'},
	$known_dashboard_id,
	'Returned data on dashboard we specified in request.',
);
