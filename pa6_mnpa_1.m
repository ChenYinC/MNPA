%constant declear
r1 = 1;
c = 0.25;
r2 =2;
L = 0.2;
r3 = 10;
alpha = 100;
r4 = 0.1;
ro = 1000;

%param declear
vin_dc = linspace(-10, 10, 20); %DC voltage
w = linspace(1, 500, 500); %AC frequency (hz)
vin_ac = 0; % AC voltage

%G matrix
G = [1 1/r1 -1/r1 0 0 0 0 0;
    0 -1/r1 (1/r1)+(1/r2) 0 0 0 1 0;
    0 1 0 0 0 0 0 0;
    0 0 0 1/r3 0 0 1 0;
    0 0 -1 1 0 0 0 0;
    0 0 0 0 1/r4 -1/r4 0 1;
    0 0 -alpha/r3 0 1 0 0 0;
    0 0 0 0 -1/r4 (1/r4)+(1/ro) 0 0];

%C matrix
C = [0 c -c 0 0 0 0 0;
    0 -c c 0 0 0 0 0;
    0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 L 0;
    0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 (alpha*L/r3) 0;
    0 0 0 0 0 0 0 0];

%(G-j*w*C)
%solve
v3 = zeros(1, 20);
vo = zeros(1, 20);
x = zeros(8, 1); % x = [I_in; Vn1; Vn2; Vn3; Vn4; Vn5; I_L; I_alpha]
for i=1:20
    F = [0; 0; vin_dc(i); 0; 0; 0; 0; 0];
    x = G\F;
    v3(i) = x(4);
    vo(i) = x(6);
end

vo_ac = zeros(1, 500);
for i=1:500
    F = [0; 0; 1; 0; 0; 0; 0; 0];
    g1 = (G - 1i*w(i).*C);
    x_ac = g1\F;
    vo_ac(i) = x_ac(6);
end

w_fixed = pi;
vo_C = zeros(1, 100);
c_rand = 0.05 * randn(1, 100) + c;
for i=1:100
    F = [0; 0; 1; 0; 0; 0; 0; 0];
    C_rand = [0 c_rand(i) -c_rand(i) 0 0 0 0 0;
            0 -c_rand(i) c_rand(i) 0 0 0 0 0;
            0 0 0 0 0 0 0 0;
            0 0 0 0 0 0 0 0;
            0 0 0 0 0 0 L 0;
            0 0 0 0 0 0 0 0;
            0 0 0 0 0 0 (alpha*L/r3) 0;
            0 0 0 0 0 0 0 0];
    g2 = (G - 1i*w_fixed.*C_rand);
    x_c = g2\F;
    vo_C(i) = x_c(6);
end

figure(1);
subplot(2, 2, 1);
plot(vin_dc, v3, vin_dc, vo);
legend('V3', 'Vo');
title('V3 and Vo');
xlabel('Vin');

subplot(2, 2, 2);
semilogx(w, real(vo_ac));

subplot(2, 2, 3);
hist(c_rand);

subplot(2, 2, 4);
hist(real(vo_C));
