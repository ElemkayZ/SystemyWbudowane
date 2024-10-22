close all; clear ;
% Parametry sygnału
A = 1;        % Amplituda sygnału
omega = 0.1;  % Częstotliwość sygnału
t = 0:0.1:100; % Wektor czasu

% Generacja sygnału
y = A * sin(omega * t);  % Sygnał sinusoidalny

% Parametry szumu jednostajnego
a = 0.5; % zakres szumu od -a do a
noise = 2 * a * rand(size(t)) - a; % generacja szumu jednostajnego w zakresie od -a do a

% Dodanie szumu do sygnału
y_noisy = y + noise;
figure;
plot(t, y,'black');
xlabel('Czas [s]');
ylabel('Amplituda');
title('Sygnał sinusoidalny bez szumu');
grid on;

figure;
plot(t, y_noisy,'g');
xlabel('Czas [s]');
ylabel('Amplituda');
title('Sygnał sinusoidalny z szumem jednostajnym');
grid on;


% Parametr H - liczba próbek do uśredniania
HArr = [2,12,80]; % np. 12 ostatnich próbek
for H = HArr
% Prealokacja wektora dla sygnału wygładzonego
y_smoothed = zeros(size(y_noisy));

% Uśrednianie H ostatnich próbek
for i = H:length(y_noisy)
    y_smoothed(i) = mean(y_noisy(i-H+1:i));
end

% Aby uniknąć nieprawidłowych wartości na początku sygnału, można zastosować inną metodę
% dla pierwszych H próbek (np. uśrednianie mniejszej liczby dostępnych próbek):
for i = 1:H-1
    y_smoothed(i) = mean(y_noisy(1:i));
end



% Rysowanie sygnału zaszumionego i wygładzonego na jednym wykresie
figure;
plot(t, y,'black', 'LineWidth', 1.5, 'DisplayName', 'Sygnał oryginalny');
hold on;
plot(t, y_noisy, 'g', 'DisplayName', 'Sygnał zaszumiony');
hold on;
plot(t, y_smoothed, 'r', 'LineWidth', 1.5, 'DisplayName', 'Sygnał wygładzony');
xlabel('Czas [s]');
ylabel('Amplituda');
title(['Wszystkie sygnały (uśrednianie ', num2str(H), ' ostatnich pomiarów)']);
legend('show');
grid on;
hold off;

figure(9);
hold on;
plot(t, y_smoothed, 'LineWidth', 1.5,  'DisplayName', ['Sygnał wygładzony(uśrednianie ', num2str(H), ' ostatnich pomiarów)']);
xlabel('Czas [s]');
ylabel('Amplituda');
legend('show');
grid on;
hold off;
end

figure(9);
hold on;
plot(t, y,'black', 'LineWidth', 1.5,  'DisplayName','Sygnał sinusoidalny bez szumu');
title('Wszystkie sygnały');
legend('show');
hold off;
% Dodanie szumu do sygnału
y_noisy = y + noise;

% Zakres H do analizy
H_values = 1:50; % Zakres H od 1 do 50
MSE_values = zeros(size(H_values)); % Prealokacja dla błędów MSE

% Obliczanie błędu średniokwadratowego dla każdego H
for idx = 1:length(H_values)
    H = H_values(idx); % Obecna wartość H
    
    % Prealokacja wektora dla sygnału wygładzonego
    y_smoothed = zeros(size(y_noisy));

    % Uśrednianie H ostatnich próbek
    for i = H:length(y_noisy)
        y_smoothed(i) = mean(y_noisy(i-H+1:i));
    end
    
    % Uśrednianie dla pierwszych H-1 próbek
    for i = 1:H-1
        y_smoothed(i) = mean(y_noisy(1:i));
    end
    
    % Obliczanie błędu średniokwadratowego (MSE)
    MSE_values(idx) = mean((y - y_smoothed).^2);
end

% Rysowanie wykresu błędu MSE w zależności od H
figure;
plot(H_values, MSE_values, 'b', 'LineWidth', 1.5);
xlabel('Liczba próbek H');
ylabel('Błąd średniokwadratowy (MSE)');
title('Błąd średniokwadratowy (MSE) w zależności od liczby próbek H');
grid on;


% Zakres wariancji szumu do analizy
var_values = linspace(0.01, 1, 50); % Zakres wariancji szumu od 0.01 do 1
MSE_values = zeros(size(var_values)); % Prealokacja dla błędów MSE

% Parametr H do uśredniania (stała wartość)
H = 10; % np. uśrednianie 10 ostatnich próbek

% Obliczanie błędu średniokwadratowego dla różnych wariancji szumu
for idx = 1:length(var_values)
    % Obecna wartość wariancji szumu
    var_noise = var_values(idx);
    
    % Generacja szumu o rozkładzie jednostajnym i odpowiedniej wariancji
    noise = sqrt(var_noise) * (2 * rand(size(t)) - 1); % Szum jednostajny o wariancji var_noise
    
    % Dodanie szumu do sygnału
    y_noisy = y + noise;

    % Prealokacja wektora dla sygnału wygładzonego
    y_smoothed = zeros(size(y_noisy));

    % Uśrednianie H ostatnich próbek
    for i = H:length(y_noisy)
        y_smoothed(i) = mean(y_noisy(i-H+1:i));
    end
    
    % Uśrednianie dla pierwszych H-1 próbek
    for i = 1:H-1
        y_smoothed(i) = mean(y_noisy(1:i));
    end
    
    % Obliczanie błędu średniokwadratowego (MSE)
    MSE_values(idx) = mean((y - y_smoothed).^2);
end

% Rysowanie wykresu błędu MSE w zależności od wariancji szumu Var(Z)
figure;
plot(var_values, MSE_values, 'b', 'LineWidth', 1.5);
xlabel('Wariancja szumu Var(Z)');
ylabel('Błąd średniokwadratowy (MSE)');
title('Błąd średniokwadratowy (MSE) w zależności od wariancji szumu');
grid on;


% Zakres wariancji szumu do analizy
var_values = linspace(0.01, 1, 50); % Zakres wariancji szumu od 0.01 do 1
optimal_H_values = zeros(size(var_values)); % Prealokacja dla optymalnych H

% Zakres H do analizy (dla każdej wartości wariancji szumu)
H_values = 1:50; % Zakres H od 1 do 50

% Obliczanie optymalnej wartości H dla różnych wariancji szumu
for idx = 1:length(var_values)
    % Obecna wartość wariancji szumu
    var_noise = var_values(idx);
    
    % Generacja szumu o rozkładzie jednostajnym i odpowiedniej wariancji
    noise = sqrt(var_noise) * (2 * rand(size(t)) - 1); % Szum jednostajny o wariancji var_noise
    
    % Dodanie szumu do sygnału
    y_noisy = y + noise;

    % Prealokacja dla MSE dla różnych H
    MSE_for_H = zeros(size(H_values));

    % Obliczanie błędu MSE dla różnych wartości H
    for h_idx = 1:length(H_values)
        H = H_values(h_idx);
        
        % Prealokacja wektora dla sygnału wygładzonego
        y_smoothed = zeros(size(y_noisy));

        % Uśrednianie H ostatnich próbek
        for i = H:length(y_noisy)
            y_smoothed(i) = mean(y_noisy(i-H+1:i));
        end
        
        % Uśrednianie dla pierwszych H-1 próbek
        for i = 1:H-1
            y_smoothed(i) = mean(y_noisy(1:i));
        end
        
        % Obliczanie błędu średniokwadratowego (MSE)
        MSE_for_H(h_idx) = mean((y - y_smoothed).^2);
    end

    % Znalezienie H, które minimalizuje MSE
    [~, optimal_H_idx] = min(MSE_for_H);
    optimal_H_values(idx) = H_values(optimal_H_idx);
end

% Rysowanie wykresu optymalnej wartości H w zależności od wariancji szumu Var(Z)
figure;
plot(var_values, optimal_H_values, 'r', 'LineWidth', 1.5);
xlabel('Wariancja szumu Var(Z)');
ylabel('Optymalna liczba próbek H');
title('Optymalna liczba próbek H w zależności od wariancji szumu');
grid on;