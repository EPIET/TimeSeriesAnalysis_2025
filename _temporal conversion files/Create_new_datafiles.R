pacman::p_load(tidyverse, rio, here)

# Practical 3
dis3 <- import(here("_temporal conversion files", "tsa_stata.dta"))   # original data
write_csv2(dis3, here("data", "tsa_pumala.csv"))

# Practical 4
mort <- import(here("_temporal conversion files/mortality.dta"))    # original data

communlab <- c(
  "Andalucía", "Aragón", "Asturias", "Baleares",
  "Canarias", "Cantabria", "Castilla y León",
  "Castilla-La Mancha", "Cataluña",
  "Comunidad Valenciana", "Extremadura",
  "Galicia", "Madrid", "Murcia", "Navarra",
  "País Vasco", "La Rioja"
)

mort <-
  mort %>%
  mutate(community2 = ordered(community, labels = communlab))

mortagg <-
  mort %>%
  group_by(year, week) %>% 
  summarise(
    cases = sum(cases, na.rm = T),
    cases_m = sum(cases_m, na.rm = T),
    cases_f = sum(cases_f, na.rm = T)
  ) %>% 
  ungroup() %>% 
  mutate(pop = rep(c(39953520, 40688520, 41423520, 42196231, 42859172,    
                     43662613,  44360521, 45236004, 45983169, 46367550), 
                   each = 52))

write_csv2(mortagg, here("data", "mortagg.csv"))


# Practical 5




