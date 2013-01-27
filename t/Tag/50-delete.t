#!perl -T

use strict;
use warnings;

use Data::Dumper;
use Data::Validate::Type;
use Test::Exception;
use Test::More;
use WebService::DataDog;


eval 'use DataDogConfig';

# We don't want to remove all tags on someone's host, so only let module author
# run this test
plan( skip_all => 'Author tests not required for installation.' )
	unless $ENV{'RELEASE_TESTING'};
	

	
my $config = DataDogConfig->new();

# Create an object to communicate with DataDog
my $datadog = WebService::DataDog->new( %$config );
ok(
	defined( $datadog ),
	'Create a new WebService::DataDog object.',
);


my $tag_obj = $datadog->build('Tag');
ok(
	defined( $tag_obj ),
	'Create a new WebService::DataDog::Tag object.',
);

my $response;


dies_ok(
	sub
	{
		$response = $tag_obj->delete( host => "xyz123" );
	},
	'Dies on unknown host name/id.',
);

ok(
	open( FILE, 'webservice-datadog-tag-host.tmp'),
	'Open temp file to read host id'
);

my $host;

ok(
	$host = do { local $/; <FILE> },
	'Read in host name/id.'
);

ok(
	close FILE,
	'Close temp file.'
);


lives_ok(
	sub
	{
		$tag_obj->delete( host => $host );
	},
	'Delete all tags on specified host.'
);

done_testing( 7 );
