function [d, im, circ, ellipse] = measure_pupil(eye_im, high, low, dist, slop)

eye_thresh = eye_im+1;
eye_thresh(eye_im>high) = 0;
eye_thresh(eye_im<low) = 0;

all_edges = edge(eye_thresh,'canny');
im.all_edges = double(all_edges);

eye_boundary = bwperim(im2bw(eye_thresh, graythresh(eye_thresh)));
all_edges(eye_boundary==1) = 0;
im.all_edges(eye_boundary==1) = 0.2;
 
pupil = eye_thresh;
im.pupil = double(pupil);
pupil(eye_boundary==1) = 0;
im.pupil(eye_boundary==1) = 0.2;
[pupil_y, pupil_x] = find(pupil);
circ.x = round(mean(pupil_x));
circ.y = round(mean(pupil_y));
circ.a = length(pupil_y);
circ.d = sqrt(circ.a*4/pi);
if not(isnan(circ.x)) & not(isnan(circ.y))
    im.pupil(circ.y, circ.x) = 0;
end

[edge_y, edge_x] = find(all_edges);
dist_from_center = sqrt((edge_x-circ.x).^2 + (edge_y-circ.y).^2);
max_dist = (1+slop)*(circ.d/2);
min_dist = (1-slop)*(circ.d/2);
bad_edges = dist_from_center>max_dist | dist_from_center<min_dist;
for ii = 1:length(bad_edges)
  if bad_edges(ii)
    all_edges(edge_y(ii), edge_x(ii)) = 0;
    im.all_edges(edge_y(ii), edge_x(ii)) = 0.4;
  end
end

empty_ellipse = struct( ...
    'a',[],...
    'b',[],...
    'phi',[],...
    'X0',[],...
    'Y0',[],...
    'X0_in',[],...
    'Y0_in',[],...
    'long_axis',0,...
    'short_axis',0,...
    'status','');
if isempty(pupil_x) | isempty(pupil_y) | isempty(edge_x) | isempty(edge_y)
    ellipse = empty_ellipse;
else
    [~, nearest_neighbor] = dsearchn([pupil_y,pupil_x], [edge_y,edge_x]);
    for ii = 1:length(nearest_neighbor)
        if nearest_neighbor(ii) > dist
            all_edges(edge_y(ii), edge_x(ii)) = 0;
            im.all_edges(edge_y(ii), edge_x(ii)) = 0.6;
        end
    end
    [pupil_xs, pupil_ys] = find(squeeze(all_edges));
    ellipse = fit_ellipse(pupil_xs,pupil_ys);
    if isempty(ellipse)
        ellipse = empty_ellipse;
    end
end

d = ellipse.long_axis;