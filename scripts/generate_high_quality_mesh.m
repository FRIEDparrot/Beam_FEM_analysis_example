function [x,y] = generate_high_quality_mesh(x1, y1, x2, y2, x3, y3)
    % 生成三个基础点，使用Bowyer-Watson算法生成高质量的Delaunay三角形剖分网格
    % 生成基础点集
    x = [x1; x2; x3];
    y = [y1; y2; y3];
    % 初始化超级三角形
    x_max = max(x);
    x_min = min(x);
    y_max = max(y);
    y_min = min(y);
    dx = x_max - x_min;
    dy = y_max - y_min;
    dmax = max(dx, dy);
    xmid = (x_max + x_min) / 2;
    ymid = (y_max + y_min) / 2;
    p1 = [xmid - 20 * dmax, ymid - dmax];
    p2 = [xmid, ymid + 20 * dmax];
    p3 = [xmid + 20 * dmax, ymid - dmax];
    tri = [1 2 3];
    % 插入点并进行Bowyer-Watson算法
    for i = 1:50 % 插入50个点
        p = [dx * rand + x_min, dy * rand + y_min];
        tri = update_triangles(tri, x, y, p);
    end
    % 去除超级三角形
    triangles = tri(tri(:,1) <= 3 & tri(:,2) <= 3 & tri(:,3) <= 3, :);
    x = x(4:end);
    y = y(4:end);
    % 绘制三角形网格
    figure;
    trimesh(triangles,x,y);
    % 添加标题和坐标轴标签
    title('High Quality Mesh');
    xlabel('x');
    ylabel('y');
end

function tri = update_triangles(tri, x, y, p)
% 使用Bowyer-Watson算法更新三角形剖分

% 找到包含点p的三角形
t = find_triangle(tri, x, y, p);

if ~isempty(t)
    % 找到与t共享边的三角形
    t1 = find_adjacent_triangle(tri, t, x, y);
    t2 = find_adjacent_triangle(tri, [t(2) t(3) t(1)], x, y);
    t3 = find_adjacent_triangle(tri, [t(3) t(1) t(2)], x, y);

    % 删除t及其共享边的三角形
    tri([t1 t2 t3],:) = [];

    % 添加新的三角形
    tri(end+1,:) = [t(1) t(2) size(x,1)+1];
    tri(end+1,:) = [t(2) t(3) size(x,1)+1];
    tri(end+1,:) = [t(3) t(1) size(x,1)+1];

    % 检查Delaunay性质并进行修正
    tri = check_delaunay(tri, x, y);
else
    warning('Point is not in any triangle');
end
end

function t = find_triangle(tri, x, y, p)
% 找到包含点p的三角形

ntri = size(tri, 1);
for i = 1:ntri
    xi = x(tri(i,:));
    yi = y(tri(i,:));
    if is_point_in_triangle(p, xi, yi)
        t = tri(i,:);
        return;
    end
end
t = [];
end

function tf = is_point_in_triangle(p, x, y)
% 判断点p是否在三角形内部    
    tf = false;
    A = (x(2)-x(1))*(y(3)-y(1))-(x(3)-x(1))*(y(2)-y(1));
    B = (x(2)-p(1))*(y(3)-p(2))-(x(3)-p(1))*(y(2)-p(2));
    C = (p(1)-x(1))*(y(3)-y(1))-(p(2)-y(1))*(x(3)-x(1));
    D = (x(2)-x(1))*(p(2)-y(1))-(y(2)-y(1))*(p(1)-x(1));
    if A >= 0
        tf = (B >= 0) && (C >= 0) && (B+C <= A);
    else
        tf = (B <= 0) && (C <= 0) && (B+C >= A);
    end
    if A == 0 % 三角形退化成一条线段
        tf = false;
    end
end

function t = find_adjacent_triangle(tri, t, x, y)
% 找到与t共享边的三角形

ntri = size(tri, 1);
for i = 1:ntri
    if isequal(tri(i,:), t)
        continue;
    end
    if any(tri(i,:) == t(1)) && any(tri(i,:) == t(2))
        xi = x(tri(i,:));
        yi = y(tri(i,:));
        if is_point_in_triangle([x(t(3)) y(t(3))], xi, yi)
            t = tri(i,:);
            return;
        end
    end
    if any(tri(i,:) == t(2)) && any(tri(i,:) == t(3))
        xi = x(tri(i,:));
        yi = y(tri(i,:));
        if is_point_in_triangle([x(t(1)) y(t(1))], xi, yi)
            t = tri(i,:);
            return;
        end
    end
    if any(tri(i,:) == t(3)) && any(tri(i,:) == t(1))
        xi = x(tri(i,:));
        yi = y(tri(i,:));
        if is_point_in_triangle([x(t(2)) y(t(2))], xi, yi)
            t = tri(i,:);
            return;
        end
    end
end
t = [];
end

function tri = check_delaunay(tri, x, y)
% 检查Delaunay性质并进行修正

ntri = size(tri, 1);
for i = 1:ntri
    xi = x(tri(i,:));
    yi = y(tri(i,:));
    for j = i+1:ntri
        xj = x(tri(j,:));
        yj = y(tri(j,:));
        [xi,yi,xj,yj] = order_points(xi,yi,xj,yj);
        if is_circle_empty(xi,yi,xj,yj,x(tri(j,3)),y(tri(j,3)))
            % 不满足Delaunay性质，进行修正
            tri(i,:) = [tri(i,2) tri(j,3) tri(i,3)];
            tri(j,:) = [tri(j,1) tri(j,2) tri(i,3)];
        end
    end
end
end

function [x1,y1,x2,y2] = order_points(x1,y1,x2,y2)
% 将两个点集按照x坐标从小到大排序

if x1(1) > x1(2)
    x1 = flip(x1);
    y1 = flip(y1);
end
if x2(1) > x2(2)
    x2 = flip(x2);
    y2 = flip(y2);
end
end

function tf = is_circle_empty(x1,y1,x2,y2,x3,y3)
% 判断以(x1,y1),(x2,y2),(x3,y3)为顶点的外接圆是否不包含任何其他点
    tf = false;
    a11 = x1 - x3;
    a12 = y1 - y3;
    a21 = x2 - x3;
    a22 = y2 - y3;
    b1 = (x1^2 - x3^2) + (y1^2 - y3^2);
    b2 = (x2^2 - x3^2) + (y2^2 - y3^2);
    detA = a11*a22 - a12*a21;
    if abs(detA) < eps % 三点共线，圆不存在
        tf = false;
    else
        xc = (b1*a11 - b2*a21)/detA;
        yc = (a11*b2 - a21*b1)/detA;
        r = sqrt((x1-xc)^2 + (y1-yc)^2);
        d = sqrt((x2-xc)^2 + (y2-yc)^2);
        e = sqrt((x3-xc)^2 + (y3-yc)^2);
        for i = 1:length(x1)
            if i == 3
                continue;
            end
            if sqrt((x1(i)-xc)^2 + (y1(i)-yc)^2) < r - eps || ...
               sqrt((x2(i)-xc)^2 + (y2(i)-yc)^2) < d - eps || ...
               sqrt((x3(i)-xc)^2 + (y3(i)-yc)^2) < e - eps
                tf = true;
                break;
            end
        end
    end
end