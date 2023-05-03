% 生成三个点
x = [0 0.5 1];
y = [0 1 0];

% 生成高质量网格
tri = generate_high_quality_mesh(x(1), y(1), x(2), y(2), x(3), y(3));

% 绘制结果
figure;
triplot(tri);
axis equal;
