function plot_labelled (points, method, labels, colors, t)

%  plot_labelled plots, either 2D or 3D, a labelled dataset.
%  either using labels designated by the order in which they appear in the 
%  data (default) or using individually designated for each point
%
%  plot_labelled(points, method, labels, colors, title)
%  where
%
%      points    The dataset in form: Coordinates x Dimension (e.g, 500 3
%                dimensional coordinates would form a 500x3 matrix)
%      method    default: 'o' (ordered) labels are plotted
%                'a' (assigned)
%      labels    If method is 'o', labels takes a matrix defining how many
%                points per label (e.g. for two equal clusters in a 1000 pt
%                dataset, use [500 500])
%                If method is 'a', labels take a single column matrix with
%                corresponding labels.
%      colors    A list of colors (e.g 'gbkr' for green, blue, black, red 
%                of [[0,0,0], [0,0,1]] for black, blue)
%      t         Title of graph
%
%  Color choices (letters)
%       
%      'r'  red (#FF0000)
%      'g'  green (#00FF00)
%      'b'  blue (#0000FF)
%      'c'  cyan (#00FFFF)
%      'm'  magenta (#FF00FF)
%      'y'  yellow (#FFFF00)
%      'k'  black (#000000)
%      'w'  white (#FFFFFF)
%

[N,dim] = size(points);

if method=='a' % convert to ordered
    [n,labels_dim] = size(labels);
    if n~=N
        msg=sprintf('Length of labels must match number of coordinates\n');
        errordlg(msg)
        return
    end
    if labels_dim~=1 
        msg1=sprintf('When using option a, labels must be an nx1 matrix\n');
        msg2=sprintf('Your matrix is %ix%i', N, labels_dim);
        msg=[msg1,msg2];
        errordlg(msg)
        return
    end
    unique_labels = unique(labels);
    labels_length = length(unique_labels);
    combined = [points labels];
    count_labels = [];
    sorted_coords = [];
    for i=1:labels_length
        l = unique_labels(i);
        idx_fil = (combined(:,end) == l);
        fil = combined(idx_fil, :);
        [ppc,~] = size(fil);
        count_labels = [count_labels ppc];
        sorted_coords = [sorted_coords; fil(:,1:end-1)];
    end
    points = sorted_coords;
    labels = count_labels;
end 

[e,labels_length] = size(labels);
unique_labels = 0:(labels_length-1);
unique_labels = unique_labels';
if e~=1
    msg1=sprintf('When using option o, labels must be an 1xn matrix\n');
    msg2=sprintf('Your matrix is %ix%i', e, labels_length);
    msg=[msg1,msg2];
    errordlg(msg)
    return
end
n = sum(labels);
if n~=N
    msg=sprintf('Length of labels must match number of coordinates\n');
    errordlg(msg)
    return
end

color_length = length(colors);
if color_length < labels_length
    msg=sprintf('You have %i colors and %i labels\n', color_length, labels_length);
    errordlg(msg)
    return
end

figure;
hold on;
n = [0 n(:)'];
current_idx = 1;
for m = 1:labels_length
    a = current_idx;
    b = a + labels(m) - 1;
    if (dim == 2)
      view(2)
      plot(points(a:b,1), points(a:b,2), 'Color', colors(:,m), 'LineStyle', 'none', 'Marker', '.');
    elseif (dim == 3)
      view(3)
      plot3(points(a:b,1), points(a:b,2),points(a:b,3), 'Color', colors(:,m), 'LineStyle', 'none', 'Marker', '.');
    end
    current_idx = b + 1;
end
title(t)
hold off;