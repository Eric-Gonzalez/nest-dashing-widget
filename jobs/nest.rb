require 'nest_thermostat'

nest_user = ENV['NEST_USER']
nest_password = ENV['NEST_PASSWORD']

use_metric_system = false

SCHEDULER.every '1m', :first_in => 0 do |job|
	nest = NestThermostat::Nest.new({email: nest_user,password: nest_password})
	first_nest = nest.status["shared"][nest.device_id]
	temp = nest.current_temp.to_i; 
	if (use_metric_system)
		temp = f_to_c(temp)
	end
	away = nest.away
	state = "off"	
	leaf_src = ""

	if(first_nest['hvac_ac_state'])
		state = "cooling"
	elsif (first_nest['hvac_heater_state'])
		state = "heating"
	end
	
	if(nest.leaf)
		leaf_src = "assets/nest_leaf.png"
	else
		leaf_src = "assets/nest_leaf_trans.png"
	end

	if(away)
		temp = "Away"
	end

	send_event('nest', { temp: temp , state: state, away: away, leaf: leaf_src })
end

# Converts fahrenheit to celcius.
def f_to_c(temp)
	return (((input - 32) * 5) / 9)
end
