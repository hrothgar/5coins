%-----------------------------------------------------------------------------%
%
% coins_plot.m
% Hrothgar, May 2013
%
% A graphical version of the Five Coins simulation. This code is nearly
% the same as  coins.m  with two primary exceptions:
%       (1) it actually computes where all the coins go
%       (2) it plots the results of each trial and then waits for
%           the user to hit a key before proceeding to another trial
%
%                            * * *
%
% Runs a simulation of the "Five Coins" problem described at
%       http://people.maths.ox.ac.uk/trefethen/invitation.pdf,
% periodically printing results to the terminal.
%
%-----------------------------------------------------------------------------%

tic;                                    %- start the clock
rng(17);                                %- set the random seed

R = 3;                                  %- outer disc radius
r = 1;                                  %- coin radius
Rr = R - r;                             %- the difference

%- This function returns `n` random points within
%- the circle of radius `r` centered at `c`.
randpoints = @(c,r,n) c + (r * rand(1,n).^0.5 .* exp(2i*pi*rand(1,n)));

%- plotting functions
circ = @(c,r) c+r*exp(2i*pi*linspace(0,1,1000));
plotcirc = @(c,r,spec,color) plot(circ(c,r),spec,'color',color);
patchcirc = @(c,r,spec,alpha) patch(real(circ(c,r)),imag(circ(c,r)),spec, ...
                                    'facealpha',alpha,'edgecolor','none');
fillcirc = @(c,r,spec) patch(real(circ(c,r)),imag(circ(c,r)),spec,'edgecolor','none');


%-----------------------------------------------------------------------------%
% The Main Loop: each iteration is a coin trial.
%-----------------------------------------------------------------------------%

trialnum = 1;                               %- trial number counter
ntestpts = 30;                              %- testing on a large number of points
                                            %- is faster than a for loop.

while 1,                                    %- until forever...

    cc = NaN(1,5);                          %- the coin centers (up to five)
    cc(1) = randpoints(0,Rr,1);             %- the fateful first coin

    %- it is always possible to drop at least three coins,
    %- so place the first three before moving on.
    c3count = 1;
    while c3count < 3,
        pts = randpoints(0,Rr,ntestpts);    %- test points

        %- find one that doesn't overlap with the others, then add it to the list.
        indx = find(all( (abs(ones(ntestpts,1)*cc-transpose(pts)*ones(1,5)) >= 2*r) ...
                                +isnan(ones(ntestpts,1)*cc), 2), 1);
        if indx,
            cc(c3count+1) = pts(indx);
            c3count = c3count + 1;
        end
    end

    %- now we find the intersection of  circle(0,Rr)
    %- with each of the three  circle(cc(k),2*r)
    %- i.e. the gray dashed circle with the red dashed circles
    %-
    %- from this we can deduce the number of open regions left (either
    %- zero, one, or two) and how many more coins we may be able to place

    cc(isnan(cc)) = [];                                 %- remove nans
    dd = abs(cc);                                       %- distances
    thetas = acos((dd.^2+Rr^2-(2*r)^2)./(2*dd*Rr));     %- law of cosines to find the angles
    pts1 = Rr*exp(1i*(angle(cc)+thetas));               %- intersection points (1)
    pts2 = Rr*exp(1i*(angle(cc)-thetas));               %- intersection points (2)

    %- weed out the ones that are overlapping other coins
    ppts1 = pts1( all(abs(transpose(pts1)*[1 1]-cc([2 3; 1 3; 1 2])) >= 2*r, 2) );
    ppts2 = pts2( all(abs(transpose(pts2)*[1 1]-cc([2 3; 1 3; 1 2])) >= 2*r, 2) );

    %- the remaining ones characterize the regions where we can still add coins
    possiblecc = [ppts1 ppts2];

    %- now find the last coin centers (if any)
    count = 3;                  %- default, assume there are only three coins
    switch length(possiblecc),  %- should never be an odd number

        %- in this first case, we have room to plant
        %- two coins in the one remaining region.
        %- 
        %- so we drop one coin and then determine if
        %- there is still room for another
        case 2
            if abs(diff(possiblecc)) >= 2*r,

                %- we'll limit where we're plucking random points
                %- in order to maximize our chances of hitting the mark
                distrc = sum(possiblecc)/2;
                radius = abs(diff(possiblecc));
                indx = [];

                while isempty(indx),
                    pts = randpoints(distrc, radius, ntestpts);

                    %- find one that doesn't overlap with the others, then add it.
                    %- this is pretty bad.. probably won't understand it when I come back to it.
                    %- but for the record, it totally works.
                    indx = find( all( (abs(ones(ntestpts,1)*cc - transpose(pts)*ones(1,3)) >= 2*r) ...
                                    + isnan(ones(ntestpts,1)*cc), 2) .* (abs(transpose(pts)) <= Rr), 1 );
                    if indx,
                        cc(4) = pts(indx);  %- add it to the list
                    end
                end

                %- the  any()  call determines if there is room for a fifth coin
                indx2 = find(abs(possiblecc - [pts(indx) pts(indx)]) >= 2*r, 1);
                if indx2,
                    cc(5) = possiblecc(indx2);
                    count = 5;
                else
                    count = 4;
                end
            else
                cc(4) = possiblecc(1);
                count = 4;
            end

        %- if there are four more possible points, then there are two distinct
        %- open regions, which means we can place two more coins
        case 4
            cc(4) = possiblecc(1);
            cc(5) = possiblecc(1+find(abs(cc(4) - possiblecc(2:end)) >= 2*r, 1));
            count = 5;
    end

%- uncomment the `if` statement to see only the trials where 5 coins make it
%if count == 5,
    %- wait before proceeding
    pause;

    %- plot everything
    c123 = cc(1:3);
    c45 = cc(4:end);

    clf; hold on;
    fillcirc(0,R,[1 .8 .8]);
    patchcirc(0,R,[1 1 1],0);   %- completely invisible, but it tweaks something right
    fillcirc(0,Rr,'w');
    for c = c123,   fillcirc(c,2*r,[1 .7 .7]); end
    for c = c123,   fillcirc(c,r,.8*[1 1 1]); end
    for c = c45,    patchcirc(c,r,[.6 .8 .6],.35); end
    for c = c123,   plotcirc(c,r,'-','k');
                    plotcirc(c,2*r,'--',[1 .4 .4]); end
    for c = c45,    plotcirc(c,r,'-',.2*[1 1 1]); end
    plotcirc(0,R,'-','k');
    plotcirc(0,Rr,'--',.4*[1 1 1]);
    plot([pts1, pts2], 'o', 'color', [.4 .4 .85], 'markersize', 8);
    plot(possiblecc, 'o', 'color', [0 .5 0], 'markersize', 8);
    plot(cc, 'x', 'color', .2*[1 1 1], 'markersize', 8)
    title(['Trial #' num2str(trialnum) '. Total coins = ' num2str(count)]);
    axis equal;
    axis(4*[-1 1 -1 1]);
    axis off;
%end

    %- increment trial number
    trialnum = trialnum + 1;
end
