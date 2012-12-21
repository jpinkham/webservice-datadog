package WebService::DataDog::Dashboard;

use strict;
use warnings;

use base qw( WebService::DataDog );

=head2 get_all_dashboards()

Retrieve details for all user-created dashboards ( does not include
system-generated or integration dashboards ).

	my $dashboard = $datadog->build('Dashboard');
	my $dashboard_list = $dashboards->get_all_dashboards();
	
Parameters: None

=cut

sub get_all_dashboards
{
	my ( $self, %args ) = @_;
#	my $verbose = $self->verbose();
	
	my $url = $WebService::DataDog::API_ENDPOINT . 'dash';
	
	return $self->_send_request(
		method => 'GET',
		url    => $url,
		data   => { '' => [] }
	);
}

1;
