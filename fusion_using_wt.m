%%
clc;
clear;
%% import data
fig_origin1 = imread("c01_1.tif");
fig_origin2 = imread("c01_2.tif");
fig_origin1 = im2double(fig_origin1);fig_origin2 = im2double(fig_origin2);
figure;
subplot(1,2,1);
imshow(fig_origin1);
subplot(1,2,2);
imshow(fig_origin2);
%% wavelet transform
fig1 = fig_origin1;
fig2 = fig_origin2;
% set the wavelet type to haar
wname = 'haar';
[row, col] = size(fig1);
% l = length;
% w = width;
iter = 2;
[c1,s] = wavedec2(fig1,iter,wname);
[c2,~] = wavedec2(fig2,iter,wname);
% % while 1
% %     if mod(l,2) == 0 && mod(w,2) == 0
% %         iter = iter+1;
% %         l = l/2;
% %         w = w/2;
% %     else
% %         break;
% %     end
% % end
% % use dwt2() to implement full 2D wavelet decomposition
% for j=iter:-1:1
%     
%     % TODO4a - select the coarse scale (subimage)
%     a1 = fig1(1:length/(2^(iter-j)),1:width/2^((iter-j)));
%     a2 = fig2(1:length/2^((iter-j)),1:width/2^((iter-j)));
%     
%     % apply dwt2 to coarse scale
%     [cA1,cH1,cV1,cD1] = dwt2(a1,wavename);
%     [cA2,cH2,cV2,cD2] = dwt2(a2,wavename);
%     
%     % TODO4b - build-up the wavelet component according to Figure 1 in labwork
%     % cA->T_phi, cH->T^H_psi, cV->T^V_psi, cD->T^D_psi
%     tmp1 = [cA1,cH1;cV1,cD1];
%     tmp2 = [cA2,cH2;cV2,cD2];
%     
%     % TODO4c - substitute wavelet component into coarse scale, iverse of
%     % TODO4a
%     fig1(1:length/(2^(iter-j)),1:width/2^((iter-j))) = tmp1;
%     fig2(1:length/(2^(iter-j)),1:width/2^((iter-j))) = tmp2;
% end
% figure;
% subplot(1,2,1);
% imshow(C);
% subplot(1,2,2);
% imshow(S);
%% fusion process
%% maximum selection rule
    
len = length(c1);
coef_fusion = zeros(1,len);
coef_fusion(1:s(1,1)*s(1,2)) = (c1(1:s(1,1)*s(1,2))+c2(1:s(1,1)*s(1,2)))/2;
mm1 = c1(s(1,1)*s(1,2)+1:len);
mm2 = c2(s(1,1)*s(1,2)+1:len);
id = abs(mm1)>abs(mm2);
mm = (mm1.*id)+(~id.*mm2);
coef_fusion(s(1,1)*s(1,2)+1:len)=mm;
% fig = zeros(length, width);
% fig = max(fig1,fig2);
% fig(1:length/2^iter,1:width/2^iter) = (fig1(1:length/2^iter,1:width/2^iter) + fig2(1:length/2^iter,1:width/2^iter));
%% mean-mean
coef_fusion = (c1+c2)/2;
%% modified feature selection algorithm
fig1 = appcoef2(c1,s,wname,iter);
fig2 = appcoef2(c2,s,wname,iter);
wd_size = 3; % specify the window size
fig1_pd = padarray(fig1,[(wd_size-1)/2,(wd_size-1)/2]);%padding
fig2_pd = padarray(fig2,[(wd_size-1)/2,(wd_size-1)/2]);
fig1_pd = dlarray(fig1_pd);fig2_pd = dlarray(fig2_pd);
fig1_mp = maxpool(fig1_pd,wd_size,'Stride',1,'DataFormat','SSCB');%maxpooling
fig2_mp = maxpool(fig2_pd,wd_size,'Stride',1,'DataFormat','SSCB');
fig1_mp = extractdata(fig1_mp);fig2_mp = extractdata(fig2_mp);
bdm = fig1_mp>fig2_mp; % binary decision map(1 for fig1,0 for fig2)
% consisteny verification
% convo = [1,1,1;1,0,1;1,1,1];
% bdm_f = zeros(size(bdm));
% bdm_m = ones(size(bdm));%initial
% while ~min(min(bdm_f == bdm_m))
iterations = 1;
i = iterations;
while i
% bdm_m = bdm;
% mid = conv2(bdm,convo,'same');
% bdm = mid>4;
% bdm_f = bdm; % final binary decision map
bdm = bwmorph(bdm,'majority');
i = i-1;
end
fig = bdm.*fig1;
fig = fig+~bdm.*fig2;

for i = iter:-1:1
    [H1,V1,D1] = detcoef2('all',c1,s,i);
    [H2,V2,D2] = detcoef2('all',c2,s,i);
    
    H1_pd = padarray(H1,[(wd_size-1)/2,(wd_size-1)/2]);%padding
    H2_pd = padarray(H2,[(wd_size-1)/2,(wd_size-1)/2]);
    V1_pd = padarray(V1,[(wd_size-1)/2,(wd_size-1)/2]);%padding
    V2_pd = padarray(V2,[(wd_size-1)/2,(wd_size-1)/2]);
    D1_pd = padarray(D1,[(wd_size-1)/2,(wd_size-1)/2]);%padding
    D2_pd = padarray(D2,[(wd_size-1)/2,(wd_size-1)/2]);
    H1_pd = abs(H1_pd);H2_pd = abs(H2_pd);
    V1_pd = abs(V1_pd);V2_pd = abs(V2_pd);
    D1_pd = abs(D1_pd);D2_pd = abs(D2_pd);
    H1_pd = dlarray(H1_pd);H2_pd = dlarray(H2_pd);
    V1_pd = dlarray(V1_pd);V2_pd = dlarray(V2_pd);
    D1_pd = dlarray(D1_pd);D2_pd = dlarray(D2_pd);
    H1_mp = maxpool(H1_pd,wd_size,'Stride',1,'DataFormat','SSCB');%maxpooling
    H2_mp = maxpool(H2_pd,wd_size,'Stride',1,'DataFormat','SSCB');
    V1_mp = maxpool(V1_pd,wd_size,'Stride',1,'DataFormat','SSCB');%maxpooling
    V2_mp = maxpool(V2_pd,wd_size,'Stride',1,'DataFormat','SSCB');
    D1_mp = maxpool(D1_pd,wd_size,'Stride',1,'DataFormat','SSCB');%maxpooling
    D2_mp = maxpool(D2_pd,wd_size,'Stride',1,'DataFormat','SSCB');
    H1_mp = extractdata(H1_mp);H2_mp = extractdata(H2_mp);
    V1_mp = extractdata(V1_mp);V2_mp = extractdata(V2_mp);
    D1_mp = extractdata(D1_mp);D2_mp = extractdata(D2_mp);
    bdmH = H1_mp>H2_mp; % binary decision map(1 for fig1,0 for fig2)
    bdmV = V1_mp>V2_mp;
    bdmD = D1_mp>D2_mp;
    % consisteny verification
%     convo = [1,1,1;1,0,1;1,1,1];
%     bdm_f = zeros(size(bdm));
%     bdm_m = ones(size(bdm));%initial
    % while ~min(min(bdm_f == bdm_m))
    i = iterations;
    while i
%     bdm_m = bdm;
%     mid = conv2(bdm,convo,'same');
%     bdm = mid>4;
%     bdm_f = bdm; % final binary decision map
    bdmH = bwmorph(bdmH,'majority');
    bdmV = bwmorph(bdmV,'majority');
    bdmD = bwmorph3(bdmD,'majority');
    i = i-1;
    end
    H = bdmH.*H1;
    H = H+~bdmH.*H2;
    V = bdmV.*V1;
    V = V+~bdmV.*V2;
    D = bdmD.*D1;
    D = D+~bdmD.*D2;
    fig = [fig,H;V,D];
    bdm = [bdm,bdmH;bdmV,bdmD];
end


% wd_size = 3; % specify the window size
% fig1_pd = padarray(fig1,[(wd_size-1)/2,(wd_size-1)/2]);%padding
% fig2_pd = padarray(fig2,[(wd_size-1)/2,(wd_size-1)/2]);
% fig1_pd = abs(fig1_pd);fig2_pd = abs(fig2_pd);
% fig1_pd = dlarray(fig1_pd);fig2_pd = dlarray(fig2_pd);
% fig1_mp = maxpool(fig1_pd,wd_size,'Stride',1,'DataFormat','SSCB');%maxpooling
% fig2_mp = maxpool(fig2_pd,wd_size,'Stride',1,'DataFormat','SSCB');
% fig1_mp = extractdata(fig1_mp);fig2_mp = extractdata(fig2_mp);
% bdm = fig1_mp>fig2_mp; % binary decision map(1 for fig1,0 for fig2)
% % consisteny verification
% convo = [1,1,1;1,0,1;1,1,1];
% bdm_f = zeros(size(bdm));
% bdm_m = ones(size(bdm));%initial
% % while ~min(min(bdm_f == bdm_m))
% iterations = 10;
% while iterations
% bdm_m = bdm;
% mid = conv2(bdm,convo,'same');
% bdm = mid>4;
% bdm_f = bdm; % final binary decision map
% iterations = iterations-1;
% end
% fig = bdm.*fig1;
% fig = fig+~bdm.*fig2;
figure;
subplot(1,2,1);
imshow(bdm);
subplot(1,2,2);
imshow(fig);
%% inverse wavelet transform
coef_fusion = [];
coef_fusion(1:(row/2^iter)*(col/2^iter)) = reshape(fig(1:row/2^iter,1:col/2^iter),1,[]);
for i = iter:-1:1
    H = reshape(fig(row/2^i+1:row/(2^(i-1)),1:col/(2^i)),1,[]);
    V = reshape(fig(1:row/(2^i),col/2^i+1:col/(2^(i-1))),1,[]);
    D = reshape(fig(row/2^i+1:row/(2^(i-1)),col/2^i+1:col/(2^(i-1))),1,[]);
    coef_fusion = [coef_fusion,V,H,D];
end
%%
% for j = 1:iter
%     
%     % TODO5a - select the coarse scale (subimage)
%     a = fig(1:length/(2^(iter-j)),1:width/2^((iter-j)));    
%     
%     % TODO5b - set the coarse scale size
%     m = length/(2^(iter-j+1));
%     n = width/(2^(iter-j+1));
%     
%     % TODO5c - apply idwt2 to coarse scale
%     % carefully choose cA and details matrices cH, cV, and cD
%     cA = a(1:m,1:n);
%     cH = a(1:m,n+1:2*n);
%     cV = a(m+1:2*m,1:n);
%     cD = a(m+1:2*m,n+1:2*n);
%     tmp = idwt2(cA, cH, cV, cD, wname);
%     
%     % TODO5d - substitute wavelet component into coarse scale
%     fig(1:length/(2^(iter-j)),1:width/2^((iter-j))) = tmp;
% end
fig = waverec2(coef_fusion,s,wname);
figure;
imshow(fig);
%% plot fusion result
figure;
subplot(1,3,1);
imshow(fig_origin1);
subplot(1,3,2);
imshow(fig_origin2);
subplot(1,3,3);
imshow(fig);