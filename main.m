% 使用有限单元方法求解悬臂梁应力，位移和变形的程序
% 将需要的函数添加到路径
tic
addpath(genpath("elements"));
addpath(genpath("load_definition")); 
addpath(genpath("meshing"))

% mm为全局单位
E = 2e5;
nu = 0.3;
thick = 10;
elem = element(E, nu, thick, 4); % 创建元素类对象

% 自动划分网格，求解网格个数
H = 28;
L = 300;

Mesh = simplemesh(H,L,4,"user-define",50,elem.elem_node_num);
%% 整体刚度矩阵的组装 -> 通过Mesh得到的节点编号, 组装整体刚度矩阵
% 进行单元的自动编号, 首先创建一个稀疏矩阵, 每一个节点的块是2x2的部分

% 计算出总体的刚度矩阵的非零元素个数来分配空间, 其个数的计算方法是一个节点本身为4
% 将单元内进行连线(矩形+ 中间的叉) ，则线代表耦合项, 一条线8
line_number = 4* Mesh. elem_number + Mesh.xelem_num + Mesh.yelem_num;
K_t = spalloc(Mesh.node_number * 2 , Mesh.node_number *2, line_number * 8 + 4 * Mesh.node_number); 
% 本例有7852个非零元素
% 首先，计算每一个1,2,3,4节点，然后赋予，但是仅赋予一半
for i = 1: Mesh.elem_number
    % 每一次直接找到对应的数组，直接进行叠加
    temp = 2 * Mesh.cord_table(:,i)';
    glob_vec = reshape([temp-1;temp], 1, 8);
    K_t(glob_vec, glob_vec) = K_t(glob_vec, glob_vec) + elem.Ke;
end

% 使用网格计算节点在对应方向上的节点力 -> pressure 使用计算获取, 由于横向50段, 0.2N/mm, 长度300mm
% 因此平均每个段上分配 1.2 N
Q = apply_pressure(Mesh, 1.2);

% 使用对角线乘大数的方法,同乘10^22
for i = 2*(Mesh.node_number-Mesh.yelem_num) -1: 2*Mesh.node_number
    K_t(i,i) = K_t(i,i) * 1e22;
    Q(i) = Q(i) * 1e22 * 0;      % 对于位移边界, 由于K_{ii} *u_{i} = Q_{i} 而u_i为0, 设置为0
end

% 雅各比矩阵的det计算,注意总体刚度矩阵组装时的系数,
J = (Mesh.dx)/2 * (Mesh.dy)/2; % 对应的雅各比矩阵

node_trans = (J * K_t)\ Q;     % 计算对应的位移矩阵

% 最终再加上固定约束
node_trans = apply_fixed_constraint(Mesh, node_trans); % 施加对应的节点约束
% 节点位移求解部分 -> 这个需要每一个节点的坐标，然后绘制u,v
u = node_trans(1:2:end-1);  % 获取每一个节点的x方向位移
v = node_trans(2:2:end);    % 获取每一个节点的y方向位移
% 求解出节点位移之后，通过偏导数，求解应力和应变矩阵
disp("======= Mesh generated successfully ========");
toc;

%% ----------- 绘制梁的变形图 -----------
Factor = 400;   % 变形放大因子
% figure("Name","Displacement");
% plot_displacement(H, Mesh, u, v, Factor); % 绘制原始和之后的变形图
% colormap spring
% title(join(["displacement with Amplification Factor", num2str(Factor)]));

figure("Name","Strain: sigma_x");
plot_stress(u,v,elem,Mesh, H, Factor);  % 求解并绘制应力图像
disp("======= Progress run ended ========");
toc

% 
% firstly, fixed the sign of the calculated result of the beam(include sigma x and sigma y), secondly the origin point of the beam is (0,0)