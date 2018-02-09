% James Durtka
% EELE 465 - Computational Computer Architecture
% Final lab: generate coefficients for an order-24 FIR filter

%number of coefficients
N = 24;
beta = 2/N;
fs = 48000;
nn = [0:N-1];

%coeffs = beta*cos((2*pi*fb*nn)/fs);
freq_domain = [zeros(1,11) ones(1,2) zeros(1,11)]
coeffs = real(ifft(freq_domain))

subplot(3,1,1)
stem(0:length(freq_domain)-1, freq_domain)
title('Desired frequency response H[k]')
subplot(3,1,2)
stem(0:length(coeffs)-1, coeffs)
title('Real\{IFFT\{H[k]\}\}')
subplot(3,1,3)
stem(0:length(coeffs)-1, real(fft(coeffs)))
title('Real\{FFT\{Real\{IFFT\{H[k]\}\}\}\}')

figure
coeffs_padded = [coeffs zeros(1,1000)];
plot(47.8*(0:length(coeffs_padded)-1)-24000, real(fft(coeffs_padded)));
title('Effective frequency response H(e^{j\omega})');

%Convert all of these to fixed point and output as hexadecimal
for i = 1:N
    %Treat as a signed 24-bit word
    val = fi(coeffs(i), 1, 24, 22);
    disp(sprintf('coeff(%i) <= x"%s";', i-1, val.hex))
end