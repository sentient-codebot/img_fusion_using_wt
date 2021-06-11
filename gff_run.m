
%% load image
% 
% file_name = "images/source22_";
% fig_origin1 = imread("source22_1.tif");
% fig_origin2 = imread("source22_2.tif");

file_name = "images/desk_";
fig_origin1 = imread(file_name+"far.tif");
fig_origin2 = imread(file_name+"near.tif");

fig_origin1 = im2single(fig_origin1);fig_origin2 = im2single(fig_origin2);

% display image
% figure
% subplot(1,2,1)
% imshow(fig_origin1,cmap)
% subplot(1,2,2)
% imshow(fig_origin2,cmap)

%% transform
tic
fig = gff(fig_origin1,fig_origin2,...
        'rg',10,...
        'r1',45,...
        'eps1',0.3,...
        'r2',7,...
        'eps2',1e-6,...
        's',3);
toc
%% display result
figure;
subplot(1,3,1)
imshow(fig_origin1)
subplot(1,3,2)
imshow(fig_origin2)
subplot(1,3,3)
imshow(fig)

%% write fused image to file
imwrite(fig,file_name+'fused.png')