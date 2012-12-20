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
	: plan( tests => 8 );

SKIP:
{
	skip( 'Temporary host tag id file is empty.', 8 )
		if (! -s 'business-datadog-tags-hostid.tmp' );

	my $config = DataDogConfig->new();
	
	# Create an object to communicate with DataDog
	my $datadog = WebService::DataDog->new( %$config );
	ok(
		defined( $datadog ),
		'Create a new WebService::DataDog object.',
	);
	
	# Pull a known host id from temp file, determined in previous test
	ok(
		open( FILE, 'business-datadog-tags-hostid.tmp'),
		'Open temp file to read host id'
	);
	
	my $known_host_id;
	
	ok(
		$known_host_id = do { local $/; <FILE> },
		'Read in known host id'
	);
	
	ok(
		close FILE,
		'Close temp file'
	);
	
	my $response;
	lives_ok(
		sub
		{
			$response = $datadog->get_tags( host => $known_host_id );
		},
		'Request specific host tag details.',
	);
	
	ok(
		Data::Validate::Type::is_hashref( $response ),
		'Retrieve response.',
	) || diag( explain( $response ) );
	
	ok(
		defined( $response->{'tags'} ),
		'We have a "tags" block in the response.',
	);
	
	ok(
		Data::Validate::Type::is_arrayref( $response->{'tags'} ),
		'"tags" block is an arrayref.',
	);
}
