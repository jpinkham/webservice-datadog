package WebService::DataDog::ServiceCheck;

use strict;
use warnings;

use base qw( WebService::DataDog );
use Carp qw( carp croak );
use Data::Dumper;
use Try::Tiny;

=head1 NAME

WebService::DataDog::ServiceCheck - Interface to ServiceCheck functions in DataDog's API.

=head1 VERSION

Version 1.0.3

=cut

our $VERSION = '1.0.3';

=head1 SYNOPSIS

This module allows you to interact with the ServiceCheck endpoint of the DataDog API.

Per DataDog: "The service check endpoint allows you to post check statuses for
use with monitors."

=head1 METHODS

=head2 check_run()

Post a status for use with monitors.

	my $service_check = $datadog->build('ServiceCheck');
	my $status = $service_check->check_run(
		check     => xx,
		host_name => $host_name,
		status    => 0,  # ['0': OK, '1': WARNING, '2': CRITICAL, '3': UNKNOWN]
		timestamp => $now,# optional. default = now; POSIX/epoch timestamp ]
		message   => $message, # optional
		tags      => $tag_list, # optional
	);
	
Parameters:

=over 4

=item * check

check description

=item * host_name

hostname description

=item * status

status desc

=item * timestamp

time stamp desc

=item * message

message desc

=item * tags

tags desc

=back

=cut

sub check_run
{
	my ( $self, %args ) = @_;
	my $verbose = $self->verbose();
	
	# Check for mandatory parameters
	foreach my $arg ( qw( check host_name status ) )
	{
		croak "ERROR - Argument '$arg' is required."
			if !defined( $args{$arg} ) || ( $args{$arg} eq '' );
	}

	# Check that status is one of the valid values
	croak "ERROR - Argument 'status' is invalid. Allowed values: 0,1,2,3"
		unless $args{'status'} =~ /^[0-3]$/;
	
}