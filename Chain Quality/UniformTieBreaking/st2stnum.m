function stnum = st2stnum(a, h, fork)
global maxForkLen
% input a, h, output the number of the state
    if a>maxForkLen || h>maxForkLen
        error('the block fork is too long')
    end
    stnum=(a*(maxForkLen+1)+h)*2+fork;
end

