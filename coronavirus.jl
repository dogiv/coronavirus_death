# Estimate chances of death from coronavirus
# for a healthy young person in the US in the next couple years.
# With uncertainty propagation.

using Random, Distributions
Random.seed!(1)

# Using normal distributions for all parameters, most of them truncated to (0,1)

p_global_pandemic = truncated(Normal(0.5, 0.2),0,1)
# off the top of my head, let's say this means that at least 0.1% of the populations
# of 10 countries on 3 continents get infected within 2 years.

current_fatality_rate = truncated(Normal(0.02, 0.005),0,1)
# reports say slightly less than 2% but who knows

# https://www.the-scientist.com/features/do-pathogens-gain-virulence-as-hosts-become-more-resistant-30219
lethality_change_over_time = truncated(Normal(0.8,0.3),0,2)
# maybe it gets a bit less lethal; but the main mechanism i have in mind here is
# that the less lethal it is, the more likely it is to spread, because our
# quarantine measures won't be quite as strict. So it's not necessarily a change
# over time, it's more like a

p_vaccine_before_US_affected_given_global = truncated(Normal(0.25,0.2),0,1)
# people seem to think vaccine development will be slow (over a year)

p_effective_antivirals_prevent_most_US_deaths = truncated(Normal(0.15,0.1),0,1)
# i haven't heard anything about antiviral use in China, but that probably just
# means it wouldn't help.

young_person_fatality_ratio_to_total_fatality = truncated(Normal(0.3, 0.2),0,2)
# they say most of the peopl dying are old or have underlying conditions like
# smoking or heart disease, but "there are outliers".

fraction_infected_in_US_given_global_spread = truncated(Normal(0.3,0.3),0,1)
# this is for the first time the infection sweeps through (however long that takes)
# and assumes no repeat infections. I also think this should negatively
# correlate with the fatality rate, but I'm not going to try to include that right
# now.

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
# Output:
# Mean death probability of a healthy young person in the US: 0.0006623629025541958
# 5th and 95th percentile: [1.8751464376174447e-5, 0.002237021565016869]
