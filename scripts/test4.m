% 节点坐标
X = [0 1 2 0.5 1.5 2.5 1 2];
Y = [0 0 0 1 1 1 2 2];
Z = [0 0 0 1 0.5 0.5 2 2];

% 三角形面片连接信息
T = [1 2 4; 2 5 4; 2 3 5; 3 6 5; 4 5 7; 5 8 7];

% 每个节点的值
C = [1 2 3 4 5 6 7 8];

% 颜色映射
colormap('jet');

% 面的透明度
alpha = ones(size(T,1),1)*0.5;

% 绘制三角形surf
fig = trisurf(T, X, Y, Z, C, 'FaceAlpha', 1);
%  'FaceAlpha', 'interp', 'AlphaData', alpha

