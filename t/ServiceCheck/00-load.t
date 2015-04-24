#!perl -T

use Test::Most 'bail', tests => 1;

BEGIN
{
	use_ok( 'WebService::DataDog::ServiceCheck' );
}

diag( "Testing WebService::DataDog::ServiceCheck $WebService::DataDog::VERSION, Perl $], $^X" );
