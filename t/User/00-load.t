#!perl -T

use Test::More tests => 1;

BEGIN
{
	use_ok( 'WebService::DataDog::User' );
}

diag( "Testing WebService::DataDog::User $WebService::DataDog::VERSION, Perl $], $^X" );
