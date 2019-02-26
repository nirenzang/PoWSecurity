function stnum = st2stnum(ab, hb, hf, last)
global maxForkLen maxafa maxhf timeOut numOfStates
assert(ab<=maxForkLen && hb<=maxForkLen);
assert(hf<=maxhf);
assert(last<2);
stnum = ((ab*(maxForkLen+1)+hb)*(maxhf+1)+hf)*2+last+1;
assert(stnum<=numOfStates);
end
