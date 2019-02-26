function stnum = st2stnum(a, h, dw, fork, last)
global maxForkLen maxDw minDw;
global tillDwNeg tillDw0 tillDw1 tillDw2 tillDw3;

assert(a<=maxForkLen && h<=maxForkLen && a>=0 && h>=0);
assert(dw>=minDw && dw<=maxDw);
assert(fork>=0 && fork<=2);
assert(last>=0);

% minDw<=Dw<0, remember a, h (both 0 to maxForkLen), dw
% tillDwNeg = (1+maxForkLen)*(1+maxForkLen)*(0-minDw);
if dw<0
    stnum = (a*(maxForkLen+1)+h)*(0-minDw)+(-1-dw)+1;
% dw=0, remember a, h, fork 
% tillDw0 = tillDwNeg+(1+maxForkLen)*(1+maxForkLen)*3;
elseif dw==0
    stnum = tillDwNeg+(a*(maxForkLen+1)+h)*3+fork+1;
% dw=1, remember a, h, fork, last (0 or 1)
% tillDw1 = tillDw0+(1+maxForkLen)*(1+maxForkLen)*3*2;
elseif dw==1
    stnum = tillDw0+((a*(maxForkLen+1)+h)*3+fork)*2+mod(last,2)+1;
% dw=2, remember a, h, fork, last (0 to 3)
% tillDw2 = tillDw1+(1+maxForkLen)*(1+maxForkLen)*3*4;
elseif dw==2
    stnum = tillDw1+((a*(maxForkLen+1)+h)*3+fork)*4+mod(last,4)+1;
% dw=3, remember a, h, fork, last (0 to 7)
% tillDw3 = tillDw2+(1+maxForkLen)*(1+maxForkLen)*3*8;
elseif dw==3
    stnum = tillDw2+((a*(maxForkLen+1)+h)*3+fork)*8+mod(last,8)+1;
% dw>3, remember a, h, dw, last (0 to 7)
% numOfStates = tillDw3+(1+maxForkLen)*(1+maxForkLen)*(maxDw-4+1)*8;
else % dw>3
    stnum = tillDw3+((a*(maxForkLen+1)+h)*8+mod(last,8))*(maxDw-3)+(dw-4)+1;
end
end

