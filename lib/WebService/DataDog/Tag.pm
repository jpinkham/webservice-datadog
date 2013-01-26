package WebService::DataDog::Tag;

use strict;
use warnings;

use base qw( WebService::DataDog );
use Carp qw( carp croak );
use Data::Dumper;
use Try::Tiny;


=head1 NAME

WebService::DataDog::Tag - Interface to Tag functions in DataDog's API.

=head1 VERSION

Version 0.6.0

=cut

our $VERSION = '0.6.0';


=head1 SYNOPSIS

This module allows you interact with the Tag endpoint of the DataDog API.

Per DataDog: "The tag end point allows you to tag hosts with keywords meaningful
to you - like role:database. All metrics sent from a host will have its tags
applied. When fetching and applying tags to a particular host, you can refer to
hosts by name (yourhost.example.com) or id (12345)."

NOTE: all methods, except retrieve_all(), operate on a per-host basis rather
than on a per-tag basis. You cannot rename a tag or delete a tag from all hosts,
through the DataDog API.


=head1 METHODS

=head2 retrieve_all()

Retrieve a mapping of tags to hosts.

	my $tag = $datadog->build('Tag');
	my $tag_host_list = $tag->retrieve_all();
	
Parameters: None

=cut

sub retrieve_all
{
	my ( $self, %args ) = @_;
	my $verbose = $self->verbose();
	
	my $url = $WebService::DataDog::API_ENDPOINT . 'tags/hosts';
	
	my $response = $self->_send_request(
		method => 'GET',
		url    => $url,
		data   => { '' => [] }
	);
	
	if ( !defined($response) || !defined($response->{'tags'}) )
	{
		croak "Fatal error. No response or 'tags' missing from response.";
	}
	
	return $response->{'tags'};
}


=head2 retrieve()

Return a list of tags for the specified host.
NOTE: a 404 response typically indicates you specified an incorrect/unknown
host name/id

	my $tag = $datadog->build('Tag');
	my $tag_list = $tag->retrieve( host => $host_name_or_id );
	
Parameters:

=over 4

=item * host

Hostname/host id you want to retrieve the tags for.

=back

=cut

sub retrieve
{
	my ( $self, %args ) = @_;
	my $verbose = $self->verbose();
	
	# Check for mandatory parameters
	foreach my $arg ( qw( host ) )
	{
		croak "ERROR - Argument '$arg' is required for retrieve()."
			if !defined( $args{$arg} ) || ( $args{$arg} eq '' );
	}
	
	my $url = $WebService::DataDog::API_ENDPOINT . 'tags/hosts' . '/' . $args{'host'};
	
	my $response = $self->_send_request(
		method => 'GET',
		url    => $url,
		data   => { '' => [] }
	);
	
	if ( !defined($response) || !defined($response->{'tags'}) )
	{
		croak "Fatal error. No response or tag 'tags' missing from response.";
	}
	
	return $response->{'tags'};
}


