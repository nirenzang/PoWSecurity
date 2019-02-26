function stnum = st2stnum(ab, hb, afA, hf, last)
global maxForkLen maxafa maxhf timeOut numOfStates
assert(ab<=maxForkLen && hb<=maxForkLen);
assert(afA<=maxafa && hf<=maxhf);
assert(last<2);
if ab<timeOut
    group = ab;
else
    group = timeOut-1+(ab-timeOut)*(maxafa+1)+afA+1;
end
stnum = ((group*(maxForkLen+1)+hb)*(maxhf+1)+hf)*2+last+1;
assert(stnum<=numOfStates);
end

