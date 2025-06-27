%% GET NUMBER OF BLOCKS PER FRAME 

nblocks(1)= size(ops.refImg,1)./ops.block_size(1); nblocks(2)=size(ops.refImg,2)./ops.block_size(2);


%% 
figure
hold on 
imshow(ops.refImg)
for r = 1:nblocks(1)
    for c = 1:nblocks(2)


    end
end

