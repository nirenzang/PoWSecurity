function numBlocks = countBlocks(history)
numBlocks = 0;
while history>0
    if mod(history,2)==1
        numBlocks = numBlocks+1;
    end
    history = floor(history/2);
end
end

