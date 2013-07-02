5coins
======

An improved estimate for the "Five Coins" problem of L.N. Trefethen described at [http://people.maths.ox.ac.uk/trefethen/invitation.pdf]. Any comments, corrections, and suggestions are gladly welcomed. Email me at hrothgarrrr@gmail.com.

Algorithm brief
---------------

The algorithm works purely geometrically. The problem is small enough to work in a case-by-case basis: in fact, there are only five different situations important to us, which are easiest to convey by image.

Note that there is *always* space for at least three coins, and that if at any time another coin can be placed in the disc, it is true (with probability one) that the coin can be placed somewhere tangent to the edge of the disc.

<style>
#coins_table tr td img {width: auto !important;}
</style>
<table id='coins_table'>
<tr>
    <td valign='top'>
        <img src='/img/c3.png' height='220px' /><br/>
        <strong>(*3)</strong> The first three coins leave no room for a fourth.
    </td>
    <td valign='top'>
        <img src='/img/c4a.png' height='220px' /><br/>
        <strong>(*4a)</strong> After laying the first three coins, there is a single region left for more coins. The region is only big enough to accommodate one coin.
    </td>
    <td valign='top'>
        <img src='/img/c4b.png' height='220px' /><br/>
        <strong>(*4b)</strong> After laying the first three coins, there is a single region left for more coins. The region is big enough to accommodate two coins, but placing the fourth leaves no room for a fifth.
    </td>
<tr>
</tr>
    <td valign='top'>
        <img src='/img/c5a.png' height='220px' /><br/>
        <strong>(*5a)</strong> After laying the first three coins, there are two disjoint regions left for more coins. Each region gets a coin, making five.
    </td>
    <td valign='top'>
        <img src='/img/c5b.png' height='220px' /><br/>
        <strong>(*5b)</strong> After laying the first three coins, there is a single region left for more coins. The region is big enough to accommodate two coins, and placing the fourth <em>does</em> leave room for a fifth.
    </td>
    <td></td>
</tr>
</table>

Results
-------

The script `coins.m`, after running for a little over 22 hours, reported these results:

    Just hit trial #423000000.
    -----------------------------------
     # coins        n            %
    -----------------------------------
        3       72954824    17.2470033
        4      327555681    77.4363312
        5       22489495     5.3166655
    -----------------------------------
    Elapsed time is 79757.280840 seconds.

A 95% confidence interval for the true value *X* of the probability that a trial admits five coins looks something like

    0.053166655 ± 2 √(0.053166655×(1-0.053166655)/423000000),

which works out to the range [0.0531884, 0.0531448]. So we can with confidence amend the estimate to the solution of the five coins problem: **X ≈ 0.0531**. Anyone will to run this thing for a few days can happily grab another digit.

Files
-----

1.  **coins.m**

    The main routine. Keeps track of progress in the 3-vector `coincoints`. By default it prints out running results every 100,000 trials (which is every 30–45 seconds on my Mac).
2.  **coins_history.m**

    The same as the main routine, but it runs a little slower since it collects information with a slightly finer granularity. Instead of simply binning the 3s, 4s, and 5s, it builds a vector `cointrials` in which each element is in {3,4,5} and corresponds to a single trial. Also prints verbose output each 100,000 trials.
3.  **coins_plot.m**

    To illustrate the problem in *stunning 2-D*, this script pauses between trials to display graphically the result of the last throw. Hit enter at the terminal to reiterate.
