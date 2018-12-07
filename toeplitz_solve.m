function x = toeplitz_solve(c, r, b)
%TOEPLITZ_SOLVE Solve a Toeplitz linear system Tx = b. 
%
% X = TOEPLITZ_SOLVE(C, R, B) solves the linear system T * X = B using the
%     algorithm presented in [1,2], implemented using the tools in 
%     hm-toolbox. 
%
% [1] 1. J. Xia, Y. Xi, and M. Gu, A superfast structured solver for 
%     Toeplitz linear systems via randomized sampling, 
%     SIAM J. Matrix Anal. Appl., 33 (2012), pp. 837-858.
%
% [1] Y. Xi, J. Xia, S. Cauley, and V. Balakrishnan, Superfast and stable 
%     structured solvers for Toeplitz least squares via randomized sampling
%     SIAM J. Matrix Anal. Appl., 35 (2014), pp. 44-72.

n = length(c);

omega = exp(1i * pi / n .* (0 : n - 1));

G = [ 1 , 2*r(1) ; zeros(n-1, 1), r(end:-1:2).' + c(2:end) ]; % G(1,2) = 2 * c(1);
H = [ c(end:-1:2) - r(2:end).' , zeros(n-1,1) ; 0 1 ];

Gh = ifft(G) * sqrt(n);
Fh = ifft((omega.' * ones(1, 2)) .* H) * sqrt(n);

dp = exp(1i * pi / n * (0 : 2 : 2*n-2));
dd = exp(1i * pi / n * (1 : 2 : 2*n));

C = hss('handle', @(v) toep_cauchy_matvec(c, r, omega, v), ...
          @(v) toep_cauchy_matvec_trasp(c, r, omega, v), ...
          @(i,j) (Gh(i, :) * Fh(j, :)') ./ (dp(i).' - dd(j)), n, n);

fv = ifft(b);
fx = C \ fv;

x = omega' .* fft(fx);

end

function z = toep_cauchy_matvec(c, r, omega, v)
    n = size(v, 1);
    v = omega' .* fft(v);
    v = toepmult_fft(c, r, n, n, v);
    z = ifft(v);
end

function z = toep_cauchy_matvec_trasp(c, r, omega, v)
    n = size(v, 1);
    v = toepmult_fft(conj(r), conj(c), n, n, fft(v));
    v = omega.' .* v;
    z = ifft(v);
end

function u = toepmult_fft(am, ap, m, n, v)
%TOEPMULT_FFT Fast multiplication of a Toeplitz matrix times a vector.
%
% U = TOEPMULT_FFT(AM, AP, M, N, V) computes the matrix-matrix product A*V
%     where A is a Toeplitz matrix defined by the vectors AM and AP and has
%     size M x N, where N = length(V).
%

realflag = isreal(am) && isreal(ap) && isreal(v);

n1=length(am);
n2=length(ap);

if (size(v, 1) == n)
    mn1 = min(n1,m);
    mn2 = min(n,n2);
    
    N = max(m + mn2, n + mn1);
    a = zeros(1,N);
    a(1:mn1) = am(1:mn1);
    a(end:-1:end-mn2+2) = ap(2:mn2);
    
    w = zeros(N,size(v,2));
    w(1:n,:) = v;
    wf=fft(w);
    af=fft(a);
    
    u = zeros(length(af), size(wf, 2));
    af = reshape(af, length(af), 1);
    
    % Choose the fastest possible way to perform the multiplication
    if size(wf, 1) > size(wf, 2)
        for i = 1 : size(wf, 2)
            u(:,i) = af .* wf(:,i);
        end
    else
        for i = 1 : size(wf, 1)
            u(i,:) = af(i) * wf(i,:);
        end
    end
    
    u = ifft(u);
    u = u(1:m,:);
    
    if (realflag)
        u = real(u);
    end
else
    error('Size mismatch in matrix vector multiplication');
end

end