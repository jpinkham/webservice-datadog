package WebService::DataDog::Alert;

use strict;
use warnings;

use base qw( WebService::DataDog );
use Carp qw( carp croak );
use Data::Dumper;


=head1 NAME

WebService::DataDog::Alert - Interface to Alert functions in DataDog's API.

=head1 VERSION

Version 0.3.1

=cut

our $VERSION = '0.3.1';


# TODO get_all_alerts
# TODO create
# TODO get_alert
# TODO update
# TODO mute_all
# TODO unmute_all
# TODO delete_alert

=head1 SYNOPSIS
This module allows you interact with the Alert endpoint of the DataDog API.

Per DataDog: "Alerts allow you to watch a particular metric query and receive a
notification when the value either exceeds or falls below the pre-defined threshold."


=head1 METHODS

=head2 get_all_alerts()

Retrieve details for all alerts.

	my $alert = $datadog->build('Alert');
	my $alert_list = $alert->get_all_alerts();
	
Parameters: None

=cut

sub get_all_alerts
{
	my ( $self, %args ) = @_;
	my $verbose = $self->verbose();
	
	my $url = $WebService::DataDog::API_ENDPOINT . 'alert';
	
	my $response = $self->_send_request(
		method => 'GET',
		url    => $url,
		data   => { '' => [] }
	);
	
	if ( !defined($response) || !defined($response->{'alerts'}) )
	{
		croak "Fatal error. No response or 'alerts' missing from response.";
	}
	
	return $response->{'alerts'};
}





=head1 AUTHOR

Jennifer Pinkham, C<< <jpinkham at cpan.org> >>.


=head1 BUGS

Please report any bugs or feature requests to C<bug-WebService-DataDog at rt.cpan.org>,
or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WebService-DataDog>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

	perldoc WebService::DataDog::Alert


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WebService-DataDog>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WebService-DataDog>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WebService-DataDog>

=item * Search CPAN

L<http://search.cpan.org/dist/WebService-DataDog/>

=back


=head1 COPYRIGHT & LICENSE

Copyright 2013 Jennifer Pinkham.

This program is free software; you can redistribute it and/or modify it
under the terms of the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut


1;