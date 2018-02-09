% James Durtka
% EELE 465 - Computational Computer Architecture
% Final lab: generate coefficients for an order-24 FIR filter

%number of coefficients
N = 24;
beta = 2/N;
fs = 48000;
nn = [0:N-1];

%This chosen because of its proximity to the midrange and also because it
%results in a real, symmetric impulse response.
fb = 4000;

%coeffs = beta*cos((2*pi*fb*nn)/fs);
freq_domain = [0.5*ones(1,8) 0 0.125*ones(1,4) 0 ones(1,4) 0 0.125*ones(1,4) 0 0.5*ones(1,8)]
coeffs = real(ifft(freq_domain))

stem(0:length(freq_domain)-1, freq_domain)
figure
stem(0:length(coeffs)-1, coeffs)
figure
stem(0:length(coeffs)-1, real(fft(coeffs)))

%Convert all of these to fixed point and output as hexadecimal
for i = 1:N
    %Treat as a signed 24-bit word
    val = fi(coeffs(i), 1, 24, 22);
    disp(sprintf('coeff(%i) <= x"%s";', i-1, val.hex))
end