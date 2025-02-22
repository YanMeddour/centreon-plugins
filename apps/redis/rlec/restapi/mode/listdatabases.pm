#
# Copyright 2022 Centreon (http://www.centreon.com/)
#
# Centreon is a full-fledged industry-strength solution that meets
# the needs in IT infrastructure and application monitoring for
# service performance.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package apps::redis::rlec::restapi::mode::listdatabases;

use base qw(centreon::plugins::mode);

use strict;
use warnings;

sub new {
    my ($class, %options) = @_;
    my $self = $class->SUPER::new(package => __PACKAGE__, %options);
    bless $self, $class;
    
    $options{options}->add_options(arguments => {});

    return $self;
}

sub check_options {
    my ($self, %options) = @_;
    $self->SUPER::init(%options);
}

sub manage_selection {
    my ($self, %options) = @_;

    $self->{databases} = $options{custom}->get(path => '/v1/bdbs');
}

sub run {
    my ($self, %options) = @_;
  
    $self->manage_selection(%options);
    foreach my $database_uid (sort keys %{$self->{databases}}) { 
        $self->{output}->output_add(
            long_msg => '[uid = ' . $database_uid . "] [name = '" . $self->{databases}->{$database_uid}->{name} . "']" .
            " [type = '" . $self->{databases}->{$database_uid}->{type} . "']" .
            " [status = '" . $self->{databases}->{$database_uid}->{status} . "']"
        );
    }
    
    $self->{output}->output_add(
        severity => 'OK',
        short_msg => 'List databases:'
    );
    $self->{output}->display(nolabel => 1, force_ignore_perfdata => 1, force_long_output => 1);
    $self->{output}->exit();
}

sub disco_format {
    my ($self, %options) = @_;
    
    $self->{output}->add_disco_format(elements => ['uid', 'name', 'type', 'status']);
}

sub disco_show {
    my ($self, %options) = @_;

    $self->manage_selection(%options);
    foreach my $database_uid (sort keys %{$self->{databases}}) {             
        $self->{output}->add_disco_entry(
            name => $self->{databases}->{$database_uid}->{name},
            type => $self->{databases}->{$database_uid}->{type},
            status => $self->{databases}->{$database_uid}->{status},
            uid => $database_uid
        );
    }
}

1;

__END__

=head1 MODE

List databases.

=over 8

=back

=cut
