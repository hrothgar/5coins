5coins
======

An improved estimate for the "5 Coins" problem of L.N. Trefethen described at [http://people.maths.ox.ac.uk/trefethen/invitation.pdf].

Files
-----

1.  **coins.m**

    The main routine. Keeps track of progress in the 3-vector `coincoints`. By default it prints out running results every 100,000 trials (which is every 30–45 seconds on my Mac).
2.  **coins_history.m**

    The same as the main routine, but it runs a little slower since it collects information with a slightly finer granularity. Instead of simply binning the 3s, 4s, and 5s, it builds a vector `cointrials` in which each element is in {3,4,5} and corresponds to a single trial. Also prints verbose output each 100,000 trials.
3.  **coins_plot.m**

    To illustrate the problem in *stunning 2-D*, this script pauses between trials to display graphically the result of the last throw. Hit enter at the terminal to reiterate.
