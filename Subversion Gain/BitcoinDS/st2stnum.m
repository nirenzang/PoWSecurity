function stnum = st2stnum(a, h, fork, matchedBeforeCfn)
global maxForkLen
assert(max(a,h)<=maxForkLen);
assert(fork<3);
assert(matchedBeforeCfn<2);
stnum=(a*(maxForkLen+1)*3+h*3+fork)*2+matchedBeforeCfn+1;
end

