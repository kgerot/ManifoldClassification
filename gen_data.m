% n = # of datapoints
n = 1000;
colormap winter(256);

t = pi + (3*pi-pi).*rand(n,1);  
u = 21.*rand(n,1);
% manifold mapping s.t. X = [tcost u tsint]
X = [t .* cos(t) u t .* sin(t)];

% https://web.archive.org/web/20040411051530/http://isomap.stanford.edu/
% http://www.numerical-tours.com/matlab/shapes_7_isomap/

% euclidean distance matrix
d_euc = squareform( pdist(X, 'euclidean' ) ); 

k = 5; % number of nearest neighbors
% connectivity
[DNN, NN] = sort(d_euc);
NN = NN(2:k+1,:);
DNN = DNN(2:k+1,:);

% adjacency matrix
B = repmat(1:n, [k 1]);
A = sparse(B(:), NN(:), ones(k*n,1));

% weighted adjacency
W = sparse(B(:),NN(:),DNN(:));

distance = full(W); % make matrix symmetric
distance = (distance+distance')/2;
distance(distance==0) = Inf;
distance(isnan(distance)) = 0;
distance = distance - diag(diag(distance));

distance(distance==Inf) = 0; % remove infinities

% plot
[row, col] = find(distance);
p = [row col]';
adj_x = X(1:n,1);
adj_y = X(1:n,2);
adj_z = X(1:n,3);

set(0,'defaultfigurecolor',[1,1,1])
subplot(2,1,1);
scatter3(X(:,1), X(:,2), X(:,3), 15, t,'filled');
grid on;
subplot(2,1,2);
plot3(adj_x(p), adj_y(p), adj_z(p), '-k');
hold on;
scatter3(X(:,1), X(:,2), X(:,3), 15, t,'filled');
grid on;
