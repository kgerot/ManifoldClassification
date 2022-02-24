clear;
addpath('../Manifold Code');

colors = 'gb';

n = 500;
ppm = [0.5*n 0.5*n];
centers = [5 12; 12 12;];
stdev = 4;
[data2,labels]=makegaussmixnd(centers,stdev,ppm);
labels = labels -1;
plotcol (data2, ppm, 'gb');
hold off;

t = data2(:,1);
u = data2(:,2);
data3 = [t.*cos(t) u t.*sin(t)];
plotcol (data3, ppm, 'gb');
hold off;


labelled_data3 = [data3 labels'];
shuffled_data3 = labelled_data3(randperm(size(labelled_data3,1)),:);


dim = 3;
d = 2;
k = 5;
X = data3';

% nearest neighbors
d_euc = squareform( pdist(data3, 'euclidean' ) ); 
[d_sort, idx] = sort(d_euc);
idx = idx(2:k+1,:); % indices of 5 nearest neighbors
d_sort = d_sort(2:k+1,:); % distances between 5 nearest neighbors
% sort returns the ascending distances 
[nn_dist, nn_idx] = sort(d_euc); 
% restrict to k closest
nn_idx = nn_idx(2:k+1,:); 
nn_dist = nn_dist(2:k+1,:);

Y_mds_a = mdscale(d_euc, 2);

labelled_mds = [Y_mds_a labels'];
shuffled_mds = labelled_mds(randperm(size(labelled_mds,1)),:);

plotcol(Y_mds_a, ppm, 'gb')
hold off;

i = 5;

% identify 
% scan from one end-to-other 
% nearest neighbor and find centroid with max diversity of labels
% variance 
% can't embed in matrix space, so bets are off for that data
% matrix
% decision with new variable

for c = 1:i
    test_start = (100*(c-1)) + 1;
    test_end = (100*c);
    test_data = shuffled_data3(test_start:test_end,1:end-1);
    test_labels = shuffled_data3(test_start:test_end,4);
    train_data = [shuffled_data3(1:test_start,1:end-1) ; shuffled_data3(test_end:end,1:end-1)];
    train_labels = [shuffled_data3(1:test_start,4) ; shuffled_data3(test_end:end,4)];
%     B = glmfit(train_data, train_labels, 'binomial');
    model = fitcknn(train_data, train_labels, 'NumNeighbors',5,'Distance','euclidean');
%     Y_hat = glmval(B, test_data, 'logit');
    Y_hat = predict(model, test_data);
    obs_pred = [Y_hat test_labels];
end


% A = nn_idx';
% 
% adj = zeros(size(A,1));
% for idx = 1:size(A,1)
%     j = nonzeros(A(idx,2:end));
%     adj(idx, j) = 1;
%     adj(j,idx) = 1;
% end
% 
% Y_mds_b = mdscale(adj, 2);
% plotcol(Y_mds_b', ppm, 'gb')
% hold off; 
