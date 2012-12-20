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

my $config = DataDogConfig->new();

# Create an object to communicate with DataDog
my $datadog = WebService::DataDog->new( %$config );
ok(
	defined( $datadog ),
	'Create a new WebService::DataDog object.',
);

my $response;

dies_ok(
	sub
	{
		$response = $datadog->get_tags();
	},
	'Request tags - do not specify host parameter.',
);


lives_ok(
	sub
	{
		$response = $datadog->get_tags( host => 'all');
	},
	'Request list of tags for all hosts.',
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
	Data::Validate::Type::is_hashref( $response->{'tags'} ),
	'"tags" block is an hashref.',
);

ok(
	open( FILE, '>', 'business-datadog-tags-hostid.tmp'),
	'Open temp file to store tags ids'
);

# Print a random host to a text file, to use in other tests
my $host_id = '';
if ( defined $response->{'tags'} && scalar( keys %{ $response->{'tags'} } > 0 ) )
{
	# Choose a random tag
	my $random_tag = (keys %{ $response->{'tags'} })[-1];
	
	# Choose the first host in the list for the random tag
	$host_id = $response->{'tags'}->{ $random_tag }->[0];
}
print FILE $host_id;

ok(
	close FILE,
	'Close temp file'
);
