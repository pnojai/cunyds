#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jul  2 17:51:11 2020

@author: jai
"""

from modsim import *

############################# PARAMETERS #####################################
#init = State(S=89, I=1, R=0)
#init /= sum(init)
tc = 3             # time between contacts in days
tr = 4             # recovery time in 
beta = 1 / tc      # contact rate in per day
gamma = 1 / tr     # recovery rate in per day

def make_system(beta, gamma):
    init = State(S=89, I=1, R=0)
    init /= sum(init)
    t0 = 0
    t_end = 7 * 14
    
    return System(init=init, t0=t0, t_end=t_end,
                  beta=beta, gamma=gamma)

def update_func(state, t, system):
    s, i, r = state
    infected = system.beta * i * s
    recovered = system.gamma * i
    s -= infected
    i += infected - recovered
    r += recovered
    
    return State(S=s, I=i, R=r)

############################# RUN VERSION 1 ################################## 
# def run_simulation(system, update_func):
#     state = system.init
#     for t in linrange(system.t0, system.t_end):
#         state = update_func(state, t, system)
#        
#     return state
#
# system = make_system(beta, gamma)
# final_state = run_simulation(system, update_func) 

########################## RUN VERSION 2 - TIME SERIES #######################
# def run_simulation(system, update_func):
#     S = TimeSeries()
#     I = TimeSeries()
#     R = TimeSeries()
    
#     state = system.init
#     t0 = system.t0
#     S[t0], I[t0], R[t0] = state
    
#     for t in linrange(system.t0, system.t_end):
#         state = update_func(state, t, system)
#         S[t+1], I[t+1], R[t+1] = state
    
#     return S, I, R

def plot_results(S, I, R):
    plot(S, '--', label='Susceptible')
    plot(I, '-', label='Infected')
    plot(R, ':', label='Resistant')
    decorate(xlabel='Time (days)',
              ylabel='Fraction of population')

# system = make_system(beta, gamma)
# S, I, R = run_simulation(system, update_func)
# plot_results(S, I, R)
    
####################### RUN VERSION 3 - TIME FRAME ###########################
def run_simulation(system, update_func):
    frame = TimeFrame(columns=system.init.index)
    frame.row[system.t0] = system.init

    for t in linrange(system.t0, system.t_end):
        frame.row[t+1] = update_func(frame.row[t], t, system)

    return frame

system = make_system(beta, gamma)
results = run_simulation(system, update_func)
plot_results(results.S, results.I, results.R)