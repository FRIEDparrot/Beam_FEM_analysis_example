function plot_stress(u,v,elem,Mesh, h, magnitude_factor)
% 绘制时需要乘放大因子
syms x y  % 事先有x, y
% 使用变形图进行绘制, 计算变形之后的x, y
% 首先计算出对应节点上面的力
% 对于每一个单元，使用节点乘对应的节点坐标得到的是位移函数

% 由于N是局部坐标系的函数, 我们选择在边缘和内部进行三点插值
% 由于\Delta 对应的是三个应变，所以对应的是三行，因此S计算的是3x1的矩阵
% 分别是 \sigma_x, \sigma_y, \tau_xy

% 在计算过程中，由于节点重复，一次只需要计算不重复的节点即可
% 一次性计算出位移，应力，应变向量并全部画出。插值计算量大,不选取插值，直接计算
displacement_vec = [u';v'];
epsilon_vec = zeros(3, Mesh.node_number);
sigma_vec = zeros(3, Mesh.node_number);
calculated_vec = false(1,Mesh.node_number);  % 创建布尔矩阵，存储某个节点是否已经被计算过

% 不在for循环中反复调用plot来节省时间
for i = 1: Mesh.elem_number
    node_index = Mesh.cord_table(:,i)';
    delta_e = reshape(displacement_vec(:,node_index), 8,1);
    % 计算函数并依次代入
    epsilon_func = elem.B * delta_e;   % 应变函数
    sigma_func = elem.S * delta_e;     % 应力函数
    xi  = [-1, 1, 1, -1];
    eta = [-1, -1, 1, 1];
    % 单元格点进行计算
    for j = 1: 4
        node_num = node_index(j);
        if calculated_vec(node_num)
            continue;
        end
        epsilon_vec(:, node_num) = subs(epsilon_func,[x, y], [xi(j), eta(j)]);
        sigma_vec(:,node_num)    = subs(sigma_func,[x,y], [xi(j), eta(j)]);
        calculated_vec(node_num) = true;
    end
end

node_displacement = sqrt(u.^2 + v.^2);

disp("========= calculated resuult =========");
disp (join(["max_sigma_x :",num2str(max(max(sigma_vec(1,:))))]));
disp (join(["max_sigma_y :",num2str(max(max(sigma_vec(2,:))))]));
disp (join(["max_shearing_force :",num2str(max(max(sigma_vec(3,:))))]));
disp (join(["max_displacement :", num2str(max(node_displacement))]));

% 绘制变形之后的位移，应力和应变图像
x_new = Mesh.node_xloc + u * magnitude_factor;
y_new = Mesh.node_yloc + v * magnitude_factor;

mat_size = [Mesh.yelem_num+1, Mesh.xelem_num+1];
X = reshape(x_new, mat_size);
Y = reshape(y_new, mat_size);
Dis = reshape(node_displacement, mat_size);
DisX = reshape(u, mat_size);
DisY = reshape(v, mat_size);
SigX = reshape(sigma_vec(1,:), mat_size);
SigY = reshape(sigma_vec(2,:), mat_size);
% 按照x,y序列重整sigma_x, sigma_y和D的规模

subplot(3,1,1);
hold on
surf(X,Y, Dis,"EdgeColor","none");
contour3(X,Y,Dis + eps, 10,"LineWidth",1.5,"ShowText","on", "LineColor","white");
colorbar;
title("displacement figure")
axis equal


subplot(3,1,2);
hold on
% ====== 绘制位移只需要把下面两行SigX改成DisX即可==========
surf(X,Y, SigX);
contour3(X,Y,SigX + eps,6,"LineWidth",1,"ShowText","on", "LineColor","white");
colorbar;
title("figure sigma_x")
axis equal

subplot(3,1,3);
hold on
surf(X,Y, SigY);
contour3(X,Y,SigY + eps,10,"LineWidth",1,"ShowText","off", "LineColor","white")
colorbar
title("figure sigma_y")
axis equal
% Sig = reshape(sigma_vec(1,:), );


end