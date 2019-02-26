function stnum = st2stnum(a, h, tie, slot1, slot2)
global tillaSmaller tillaEqual tillaOneBigger range;
assert(a>=0 && h>=0 && a+h>0);
% when a<h, remember a (0 to h-1), h (1 to maxForkLen), htop (0 to range-1)
% htop=slot1;
% tillaSmaller = (1+maxForkLen)*maxForkLen/2*range;
if a<h
    % assert(slot1>=0 && slot1<=range);
    stnum = (h*(h-1)/2+a)*range+slot1+1;
% when a==h>0 remember a/h (1 to maxForkLen) and tie
% tillaEqual = tillaSmaller+maxForkLen*2;
elseif a==h && a>0
    assert(tie==0 || tie==1);
    stnum = tillaSmaller+(a-1)*2+tie+1;
% when a==h+1, remember a (1 to maxForkLen) atop1 (0 to range-1)and tie (0 or 1)
% when h==0, tie is defined as hWin, to prevent attacker from overriding
%     with 0 blocks
% atop1=slot1;
% tillaOneBigger = tillaEqual+maxForkLen*2*range;
elseif a==h+1
    assert((tie==0 || tie==1))% && (slot1>=0 && slot1<=range));
    stnum = tillaEqual+((a-1)*2+tie)*range+slot1+1;
% when a>h+1, remember a (2 to maxForkLen), h(0 to maxForkLen-2), atop1 (0
%     to range-1), atop2
% atop1 = slot1, atop2 = slot2
% numOfStates = tillaOneBigger+maxForkLen*(maxForkLen-1)/2*range*range;
elseif a>h+1
    % assert((slot2>=0 && slot2<=range) && (slot1>=0 && slot1<=range));
    stnum = tillaOneBigger+(((a-2)*(a-1)/2+h)*range+slot1)*range+slot2+1;
else
    error('illegal state')
end

