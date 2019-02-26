function stnum = st2stnum( a,h,fork)
global maxForkLen
% input a, h, fork, output the number of the state
% fork: 0 means irrelevant, 1 means relevant, 2 means active
    if a>maxForkLen || h>maxForkLen
        error('the block fork is too long')
    end
    stnum=a*(maxForkLen+1)*3+h*3+fork + 1;
end

