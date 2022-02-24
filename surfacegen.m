clear;
f1 = @(x,y) 2*(erf(x)+cos(y));

n = 100;
x = -2 + (4).*rand(n,1); % between -2 and 2
y = -5 + (6).*rand(n,1); % between -5 and 1
z = f1(x,y);
X = [x y z];

view = [-2 2 -5 1];
colormap winter(256);

subplot(2,1,1);
fsurf(f1,view,'EdgeColor','none','FaceAlpha',0.3)
hold on;
scatter3(x,y,z,10,'k','filled');

set(gca,'YTick',[])
set(gca,'ZTick',[])
set(gca,'XTick',[])

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

hold on;
subplot(2,1,2);
fsurf(f1,view,'EdgeColor','none','FaceAlpha',0.3)
hold on;
plot3(adj_x(p), adj_y(p), adj_z(p), '-k');
hold on;
scatter3(x,y,z,10,'k','filled');
set(gca,'YTick',[])
set(gca,'ZTick',[])
set(gca,'XTick',[])
