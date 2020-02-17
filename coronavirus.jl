# Estimate chances of death from coronavirus
# For a healthy young person in the US
# Taking into account uncertainty

using Random, Distributions
Random.seed!(1)

p_global_pandemic = truncated(Normal(0.5, 0.2),0,1)
current_fatality_rate = truncated(Normal(0.02, 0.01),0,1)

# https://www.the-scientist.com/features/do-pathogens-gain-virulence-as-hosts-become-more-resistant-30219
lethality_change_over_time = truncated(Normal(0.8,0.3),0,2)

p_vaccine_before_US_affected_given_global = truncated(Normal(0.25,0.2),0,1)
p_effective_antivirals_prevent_most_US_deaths = truncated(Normal(0.15,0.1),0,1)

young_person_fatality_ratio_to_total_fatality = truncated(Normal(0.3, 0.2),0,2)

fraction_infected_in_US_given_global_spread = truncated(Normal(0.3,0.3),0,1)
# this is for the first time the infection sweeps through (however long that takes)
# and assumes no repeat infections

n = 10000
# Monte Carlo: take a thousand samples from each distr
p_global = rand(p_global_pandemic, n)
current_fatal = rand(current_fatality_rate, n)
lethality_change = rand(lethality_change_over_time, n)
fatality_rate_given_global = current_fatal .* lethality_change
p_vaccine = rand(p_vaccine_before_US_affected_given_global, n)
p_antiviral = rand(p_effective_antivirals_prevent_most_US_deaths)
ratio = rand(young_person_fatality_ratio_to_total_fatality, n)
fraction_infected = rand(fraction_infected_in_US_given_global_spread, n)

young_person_death_probabilities = p_global .* fatality_rate_given_global .*
    (1 .- p_vaccine) .* (1 .- p_antiviral) .* ratio .* fraction_infected

println("Mean death probability of a healthy young person in the US: ", mean(young_person_death_probabilities))
println("5th and 95th percentile: ", quantile(young_person_death_probabilities, [0.05, 0.95]))
