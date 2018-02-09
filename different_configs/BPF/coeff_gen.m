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

coeffs = beta*cos((2*pi*fb*nn)/fs);

stem(coeff_indices,coeffs);

%Convert all of these to fixed point and output as hexadecimal
for i = 1:N
    %Treat as a signed 24-bit word
    val = fi(coeffs(i), 1, 24, 22);
    disp(sprintf('coeff(%i) <= x"%s";', i-1, val.hex))
end