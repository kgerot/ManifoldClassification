function plotcol (points, ppm, colors)

M = length(colors);
figure;
hold on;
cumppm = cumsum(ppm);
cumppm = [0 cumppm(:)'];
[~,dim] = size(points);
for m = 1:M
    a = cumppm(m)+1;
    b = cumppm(m+1);
    if (dim == 2)
      view(2)
      plot ( points(a:b,1), points(a:b,2), [ colors(m) '.' ] );
    elseif (dim == 3)
      view(3)
      plot3 ( points(a:b,1), points(a:b,2),points(a:b,3), [ colors(m) '.' ] );
    end
end