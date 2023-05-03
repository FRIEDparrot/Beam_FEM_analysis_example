function plot_displacement(h, Mesh , u, v, magnitude_factor)
% 绘制位移状况
x_new = Mesh.node_xloc + u*magnitude_factor;
y_new = Mesh.node_yloc + v*magnitude_factor;
d = sqrt(u.^2 + v.^2);
% 绘制位移彩色图, 首先计算各点的位移函数

X = reshape(x_new,Mesh.yelem_num+1, Mesh.xelem_num+1);
Y = reshape(h-y_new, Mesh.yelem_num+1, Mesh.xelem_num +1);
D = reshape(d, Mesh.yelem_num+1, Mesh.xelem_num +1);

axis equal
colormap default
hold on
contour3(X,Y,D+eps,25,"LineWidth",1,"ShowText","off", "LineColor","white");
surf(X,Y,D, "EdgeColor","none");  % 其中参数c是投影到z = 0上面
colorbar
% 绘制网格图
% hold on
% for i = 1:length(Mesh.conn)
%     node1 = Mesh.conn(1, i);
%     node2 = Mesh.conn(2, i);
%     x01 = Mesh.node_xloc(node1); 
%     x02 = Mesh.node_xloc(node2);
%     y01 = h - Mesh.node_yloc(node1);
%     y02 = h - Mesh.node_yloc(node2);
%     x1 = x_new(node1); y1 = h - y_new(node1);
%     x2 = x_new(node2); y2 = h - y_new(node2);
%     plot ([x01, x02], [y01, y02],'-k', 'MarkerSize',2);
%     plot ([x1, x2], [y1, y2] ,'--b');
% end
end