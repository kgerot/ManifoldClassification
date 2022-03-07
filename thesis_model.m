function model=thesis_model(data,labels,k)

%  thesis_model returns a classification model composed of knn
%  classification and logistic regression as well as a delauney
%  triangulation which defines the area where regression is used
%
%  thesis_model(data, labels,k)
%  where
%
%      data      A matrix where each row is an n-dimensional coordinate
%      labels    An nx1 matrix with labels corresponding to data points
%      k         Number of nearest neighbors to use
%

clear;
addpath('../ManifoldClassification');

% parameters
n = 5000; % number of points
k = 5; % number of nearest neighbors

% create data
ppm = [0.5*n 0.5*n];
centers = [5 12; 12 12;];
stdev = 2;
[data2,labels]=makegaussmixnd(centers,stdev,ppm);
labels = labels -1;

% convert to manifold
t = data2(:,1);
u = data2(:,2);
data3 = [t.*cos(t) u t.*sin(t) labels'];
data3 = data3(randperm(size(data3,1)),:);
labels = data3(:,end);
coords = data3(:,1:end-1);
% clean up workspace
clearvars data2 t u stdev;

% k nearest neighbors
d_euc = squareform( pdist(coords, 'euclidean' ) ); 
[nn_dist, nn_idx] = sort(d_euc);
nn_idx = nn_idx(2:k+1,:); % indicies
nn_dist = nn_dist(2:k+1,:); % distances between nearest neighbors
% clean up workspace
clearvars d_euc;


% adjacency matrix & diversity scores
adj = zeros(n,n); % adjacency matrix
pre_div = zeros(k,n); % preliminary diversity scores
div_scores = zeros(n,n);
for c = 1:n
    col = nn_idx(:,c);
    for cc = 1:k
        idx = col(cc);
        adj(idx,c) = 1;
        pre_div(cc,c) = ~(labels(idx) == labels(c));
    end
    div_scores(c,:) = adj(c,:)*(sum(pre_div(:,c))/k);
end
% based on k nearest neighbors and their k nearest neighbours
div = zeros(n,1); % diversity scores [0,1] where 1 is most heterogenous
for c = 1:n
    div(c) = sum(div_scores(:,c))/(k);
end
% clean up workspace
clearvars pre_div div_scores idx col c cc;

div_sort = sortrows(div);
max_div = div_sort(end); % maximum diversity score
st = std(div(div>0)); % standard deviation of diversity scores
% range of scores based on standard deviation
range = [max_div-(2*st) max_div]; 

% Plot diversity scores & threshold
plot(1:n, div_sort, '-')
title('Diversity Scores')
hold on
plot([1 n], [range(1) range(1)], 'r-')
hold off;
% clean up workspace
clearvars max_div div_sort st;

% find point cloud
method = zeros(n,1);
idx_range = find(div > range(1));
method(idx_range) = 1;

% find convex hull
cloud_nn = unique(reshape(nn_idx(:,idx_range)',[],1));
cloud = coords(cloud_nn,:);
ch = delaunayn(cloud); % delaunay triangulation
% find points in hull
in_hull = ~isnan(tsearchn(cloud, ch, coords));
cloud_idx = find(in_hull);

method(cloud_idx) = 1;
% plot manifold with clusters
plot_labelled(coords, 'a', labels, 'gb', 'Manifold');
% plot method separation
plot_labelled(coords, 'a', method, 'kr', 'nn Point Cloud');

B = glmfit(train_data, train_labels, 'binomial');
Y_hat = glmval(B, test_data, 'logit');

knn_model = fitcknn(coords, labels, 'NumNeighbors',k, ...
    'Distance','euclidean', 'KFold',10);
knn_L = kfoldLoss(knn_model);


% near close error
% quantifying uncertainty ^ ?
% F1 graph with inflection point