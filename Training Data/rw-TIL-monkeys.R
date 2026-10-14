#####  Simulation illustrating predictions of Rescorla-Wagner model ############
#####  with a backward transfer of value from a terminal item  #################
#####  developed for Babb et al., TIL task with capuchin monkeys ##############
################################################################################

library(ggplot2)
library(dplyr)
library(tidyr)

rm(list=ls(all=TRUE))

####  R-W update function ####################################################
#weight scales the learning rate; it is 1 for direct reinforcement/
#nonreinforcement and equals transfer for backward value transfer
update <- function(stim, lambda, weight = 1) {
  V[stim] <<- V[stim] + weight * alpha * (lambda - V[stim])}

#function for training a single sequence
train_sequence <- function(seq) {
  
  #determine whether the sequence was completed correctly
  correct <- runif(1) < p_correct
  
  if (correct) {
    
    #directly reinforce the terminal item
    update(seq[3], lambda = 1)
    
    #transfer value backward from the terminal item to the second item,
    #then from the second item to the first item
    update(seq[2], lambda = V[seq[3]], weight = transfer)
    update(seq[1], lambda = V[seq[2]], weight = transfer)} 
  else {
    
    #on an incorrect trial, assume that 2/3 of errors involve
    #the terminal item and 1/3 involve the second item
    r <- runif(1)
    
    if (r < 2/3) {
      
      #nonreinforce the terminal item
      update(seq[3], lambda = 0)} 
    else {
      #nonreinforce the second item
      update(seq[2], lambda = 0)
    }}}

##### Save values function ###########################
save_values <- function(phase) {
  data.frame(
    phase = phase,
    item = names(V),
    value = as.numeric(V))}

###############################################################################
##### Simulation following the five phases of monkey training #################
###############################################################################

set.seed(123)

alpha <- 0.2 #learning rate
transfer <- 0.2 #transfer rate

#create dataset for training items
items <- c("A","B","C","D","E","F","G")

#vector to hold associative values
V <- setNames(rep(0, length(items)), items)

#dataset to keep changes in values
history <- data.frame()

#set training sequences
sequences <- list(c("A","B","C"), c("C","D","E"),  c("E","F","G"))

#trials per sequence within each phase, based on median trials to criterion
phase_trials <- c(300, 200, 200, 100, 450)

#Griffin trials for comparison
#phase_trials <- c(480, 276, 2688, 96, 361)

p_correct <- 0.80 #criterion-level accuracy

####Phase 1: Sequence 1 only (A -> B -> C)
for (i in 1:phase_trials[1]) {
  train_sequence(sequences[[1]])}

history <- bind_rows(history, save_values("Phase 1"))

####Phase 2: Sequence 2 only (C -> D -> E)
for (i in 1:phase_trials[2]) {
  train_sequence(sequences[[2]])}

history <- bind_rows(history, save_values("Phase 2"))

####Phase 3: Sequences 1 and 2 intermixed
phase3 <- sample(rep(1:2, each = phase_trials[3]))

for (s in phase3) {
  train_sequence(sequences[[s]])}

history <- bind_rows(history, save_values("Phase 3"))

####Phase 4: Sequence 3 only (E -> F -> G)
for (i in 1:phase_trials[4]) {
  train_sequence(sequences[[3]])}

history <- bind_rows(history, save_values("Phase 4"))

####Phase 5: all three sequences intermixed
phase5 <- sample(rep(1:3, each = phase_trials[5]))

for (s in phase5) {
  train_sequence(sequences[[s]])}

history <- bind_rows(history, save_values("Phase 5"))

#### Create Figure S1
history$phase <- factor(history$phase,
  levels = paste("Phase", 1:5))

#label terminal and non-terminal items
history$role <- ifelse(history$item %in% c("C", "E", "G"),
  "Terminal", "Non-Terminal")

history$role <- factor(history$role,levels = c("Non-Terminal", "Terminal"))
 
figS1 <- ggplot(history, aes(x = phase, y = value, group = item, color = role)) +
  geom_line(linewidth = 0.7) + geom_point(size = 2.5) +
  facet_wrap(~item, ncol = 4) +
  scale_color_manual(values = c("Non-Terminal" = "#0072B2","Terminal" = "#CC79A7")) +
  scale_x_discrete(labels = c("Phase 1" = "1","Phase 2" = "2","Phase 3" = "3",
                              "Phase 4" = "4","Phase 5" = "5")) +
  scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.25))+
  labs(x = "Training Phase",y = "Associative Value" ) +theme_classic(base_size = 14) +  
  theme(legend.title = element_blank(), strip.background = element_rect(fill = "white",
      color = "black"), strip.text = element_text(face = "bold", size = 14),
    panel.spacing = unit(0.8, "lines"))

figS1
ggsave("FigureS1.png", figS1, width = 8, height = 4, units = 'in', dpi = 300)

####Create Figure S2
#create dataframe to plot the values
df <- data.frame(item = factor(names(V), levels = c("A","B","C","D","E","F","G")),
  value = as.numeric(V))

#label terminal and non-terminal items
df$role <- ifelse(df$item %in% c("C", "E", "G"),
                       "Terminal", "Non-Terminal")

df$role <- factor(df$role, levels = c("Non-Terminal","Terminal"))

#plot values
figS2<-ggplot(df, aes(x = item, y = value, fill = role)) +
  geom_col(color = "black", width = 0.7) +
  scale_fill_manual(values = c("Non-Terminal" = "#0072B2",
    "Terminal" = "#CC79A7")) +
  labs(x = "Item", y = "Associative value") +
  theme_classic(base_size = 14) + theme(legend.title = element_blank())

figS2

#export as png
ggsave("FigureS2.png", figS1, width = 5, height = 3, units = 'in', dpi = 300)

