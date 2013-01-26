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

my $tag_obj = $datadog->build('Tag');
ok(
	defined( $tag_obj ),
	'Create a new WebService::DataDog::Tag object.',
);

my $response;
lives_ok(
	sub
	{
		$response = $tag_obj->retrieve_all();
	},
	'Request list of all tags for all hosts.',
);

ok(
	defined( $response ),
	'Response was received.'
);

ok(
	Data::Validate::Type::is_hashref( $response ),
	'Response is an hashref.',
);


# Store id for use in upcoming tests: update, retrieve
ok(
	open( FILE, '>', 'webservice-datadog-tag-host.tmp'),
	'Open temp file to store host name/id.'
);

# Grab the first hash key (tag)
my $first_tag = (keys %$response)[0];
# Print the first host for the first hash key (tag)
print FILE $response->{ $first_tag }->[0];

ok(
	close FILE,
	'Close temp file.'
);
