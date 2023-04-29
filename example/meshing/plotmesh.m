function plotmesh(Mesh)
% 绘制网格函数
x = 0: Mesh.dx: Mesh.length;  % 每一个x值是一个节点
y = 0: Mesh.dy: Mesh.height;
[X,Y] = meshgrid(x,y);
clear x y
% 创建一个随机颜色矩阵
colors = rand(Mesh.yelem_num + 1, Mesh.xelem_num + 1);   % 注意是yelem_num和xelem_num
% colors = zeros(Mesh.yelem_num + 1, Mesh.xelem_num + 1);
fig = pcolor(X,Y,colors);  % ,colors 可创建对应的颜色, 注意不要重名
set(fig, 'EdgeColor', 'black');
axis equal
