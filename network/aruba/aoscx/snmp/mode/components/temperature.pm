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

package network::aruba::aoscx::snmp::mode::components::temperature;

use strict;
use warnings;

my $mapping = {
    name        => { oid => '.1.3.6.1.4.1.47196.4.1.1.3.11.3.1.1.5' }, # arubaWiredTempSensorName
    state       => { oid => '.1.3.6.1.4.1.47196.4.1.1.3.11.3.1.1.6' }, # arubaWiredTempSensorState
    temperature => { oid => '.1.3.6.1.4.1.47196.4.1.1.3.11.3.1.1.7' }  # arubaWiredTempSensorTemperature
};
my $oid_arubaWiredTempSensorEntry = '.1.3.6.1.4.1.47196.4.1.1.3.11.3.1.1';

sub load {
    my ($self) = @_;
    
    push @{$self->{request}}, {
        oid => $oid_arubaWiredTempSensorEntry,
        start => $mapping->{name}->{oid},
        end => $mapping->{temperature}->{oid}
    };
}

sub check {
    my ($self) = @_;
    
    $self->{output}->output_add(long_msg => 'checking temperatures');
    $self->{components}->{temperature} = { name => 'temperatures', total => 0, skip => 0 };
    return if ($self->check_filter(section => 'temperature'));

    foreach my $oid ($self->{snmp}->oid_lex_sort(keys %{$self->{results}->{$oid_arubaWiredTempSensorEntry}})) {
        next if ($oid !~ /^$mapping->{state}->{oid}\.(.*)$/);
        my $instance = $1;
        my $result = $self->{snmp}->map_instance(mapping => $mapping, results => $self->{results}->{$oid_arubaWiredTempSensorEntry}, instance => $instance);

        next if ($self->check_filter(section => 'temperature', instance => $instance, name => $result->{name}));
        $self->{components}->{temperature}->{total}++;

        $result->{temperature} /= 1000;

        $self->{output}->output_add(
            long_msg => sprintf(
                "temperature '%s' status is %s [instance: %s, current: %.2f C]",
                $result->{name},
                $result->{state},
                $instance,
                $result->{temperature}
            )
        );
        my $exit = $self->get_severity(label => 'default', section => 'temperature', value => $result->{state});
        if (!$self->{output}->is_status(value => $exit, compare => 'ok', litteral => 1)) {
            $self->{output}->output_add(
                severity =>  $exit,
                short_msg => sprintf(
                    "temperature '%s' status is %s",
                    $result->{name}, $result->{state}
                )
            );
        }
        
        next if (!defined($result->{temperature}));
        
        my ($exit2, $warn, $crit, $checked) = $self->get_severity_numeric(section => 'temperature', instance => $instance, name => $result->{name}, value => $result->{temperature});
        if (!$self->{output}->is_status(value => $exit2, compare => 'ok', litteral => 1)) {
            $self->{output}->output_add(
                severity => $exit2,
                short_msg => sprintf(
                    "temperature '%s' is %.2f C",
                    $result->{name},
                    $result->{temperature}
                )
            );
        }
        $self->{output}->perfdata_add(
            unit => 'C',
            nlabel => 'hardware.temperature.celsius',
            instances => $result->{name},
            value => sprintf('%.2f', $result->{temperature}),
            warning => $warn,
            critical => $crit
        );
    }
}

1;
