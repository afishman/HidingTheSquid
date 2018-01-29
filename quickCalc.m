clear all

lambda_pre = 3;
lambda_c = 4;

lambda_p = 1.25;

M = 5;

dc = 5;

dp = dc*(M/(M-1))*(lambda_pre - lambda_c)/(lambda_p - lambda_pre);
dp = ceil(dp);

L =lambda_pre*( M*dc + (M-1)*dp);

disp(L);DE