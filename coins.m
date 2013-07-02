%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% coins.m
% Hrothgar, May 2013
%
% Runs a simulation of the "Five Coins" problem described at
%       http://people.maths.ox.ac.uk/trefethen/invitation.pdf,
% periodically printing results to the terminal.
%
% The results of the Monte Carlo trials are collected in `coincounts`,
% a 3-vector corresponding to the frequency of 3, 4, and 5 coins being
% placed during the trials.  I.e. `coincounts` = [#3s #4s #5s].
%
% This code doesn't actually compute where all the coins go --
% it doesn't have to. It only computes how many coins there are.
%
% On my MacBook Pro I compute around 5200 trials/sec.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic;                                    % start the clock
rng(1);                                 % set the random seed
outputinterval = 1e5;                   % verbose output interval

R = 3;                                  % outer disc radius
r = 1;                                  % coin radius
Rr = R - r;                             % the difference
coincounts = zeros(1,3);                % the results of the monte carlo trials

% This function returns `n` random points within
% the circle of radius `r` centered at `c`.
randpoints = @(c,r,n) c + (r * rand(1,n).^0.5 .* exp(2i*pi*rand(1,n)));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Main Loop: each iteration is a coin trial.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

trialnum = 1;  % trial number counter
ntestpts = 30; % testing on a large number of points
               % is faster than a for loop.

while 1,       % until forever...

    cc = NaN(1,5);              % the coin centers (up to five)
    cc(1) = randpoints(0,Rr,1); % the fateful first coin

    % it is always possible to drop at least three coins,
    % so place the first three before moving on.
    c3count = 1;
    while c3count < 3,
        pts = randpoints(0,Rr,ntestpts);    % test points

        % find one that doesn't overlap with the others, then add it to the list.
        indx = find(all( (abs(ones(ntestpts,1)*cc-transpose(pts)*ones(1,5)) >= 2*r) ...
                                +isnan(ones(ntestpts,1)*cc), 2), 1);
        if indx,
            cc(c3count+1) = pts(indx);
            c3count = c3count + 1;
        end
    end

    % now we find the intersection of  circle(0,Rr)
    % with each of the three  circle(cc(k),2*r)
    % i.e. the gray dashed circle with the red dashed circles
    %
    % from this we can deduce the number of open regions left (either
    % zero, one, or two) and how many more coins we may be able to place
    %
    cc(isnan(cc)) = [];                             % remove nans
    dd = abs(cc);                                   % distances
    thetas = acos((dd.^2+Rr^2-(2*r)^2)./(2*dd*Rr)); % law of cosines to find the angles
    pts1 = Rr*exp(1i*(angle(cc)+thetas));           % intersection points (1)
    pts2 = Rr*exp(1i*(angle(cc)-thetas));           % intersection points (2)

    % weed out the ones that are overlapping other coins
    ppts1 = pts1( all(abs(transpose(pts1)*[1 1]-cc([2 3; 1 3; 1 2])) >= 2*r, 2) );
    ppts2 = pts2( all(abs(transpose(pts2)*[1 1]-cc([2 3; 1 3; 1 2])) >= 2*r, 2) );

    % the remaining ones characterize the regions where we can still add coins
    possiblecc = [ppts1 ppts2];

    % now find the last coin centers (if any)
    count = 3;                  % default, assume there are only three coins
    switch length(possiblecc),  % should never be an odd number

        % in this first case, we have room to plant
        % two coins in the one remaining region.
        % 
        % so we drop one coin and then determine if
        % there is still room for another
        case 2
            if abs(diff(possiblecc)) >= 2*r,

                % we'll limit where we're plucking random points
                % in order to maximize our chances of hitting the mark
                distrc = sum(possiblecc)/2;
                radius = abs(diff(possiblecc));
                indx = [];

                while isempty(indx),
                    pts = randpoints(distrc, radius, ntestpts);

                    % find one that doesn't overlap with the others, then add it.
                    % this is pretty bad.. probably won't understand it when I come back to it.
                    % but for the record, it totally works.
                    indx = find( all( (abs(ones(ntestpts,1)*cc - transpose(pts)*ones(1,3)) >= 2*r) ...
                                    + isnan(ones(ntestpts,1)*cc), 2) .* (abs(transpose(pts)) <= Rr), 1 );
                    if indx,
                        cc(4) = pts(indx);  % add it to the list
                    end
                end

                % the  any()  call determines if there is room for a fifth coin
                count = 4 + any(abs(possiblecc - [pts(indx) pts(indx)]) >= 2*r);
            else
                count = 4;
            end

        % if there are four more possible points, then there are two distinct
        % open regions, which means we can place two more coins
        case 4
            count = 5;
    end

    % add this coin count to the list
    coincounts(count-2) = coincounts(count-2) + 1;

    % if we're at a lucky number, print out the results so far
    if ~mod(trialnum,outputinterval),
        values = [3:5; coincounts; coincounts/trialnum*100];
        disp(['Just hit trial #' num2str(trialnum) '.'])
        disp(['---------------------------------'])
        disp([' # coins       n          %'])
        disp(['---------------------------------'])
        fprintf(['    %d    %8d     %10.7f\n'], values)
        disp(['---------------------------------'])
        toc
        disp(' ')
    end

    % increment trial number
    trialnum = trialnum + 1;
end
